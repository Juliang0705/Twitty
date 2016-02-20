//
//  UserViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/17/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

func hexStringToUIColor (hex:String,alpha: CGFloat) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.grayColor()
    }
    
    var rgbValue:UInt32 = 0
    NSScanner(string: cString).scanHexInt(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var userDescription: UITextView!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var user:User?
    var tweets:[Tweet]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTappedAction:", name: statusBarTappedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: statusBarTappedNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.tableHeaderView = headerView
        self.navigationController?.navigationBar.topItem?.title = "";
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.backgroundColor = UIColor(red: 242.0 / 255.0, green: 246.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
        self.tableView.backgroundView = backgroundView
        
        if let user = self.user{
            TwitterClient.sharedInstance.userTimelineWithParams(["user_id":user.userID!], completion: { (tweets, error) -> () in
                if (error == nil){
                    self.tweets = tweets
                    self.tableView.reloadData()
                }else{
                    print(error)
                }
            })
            self.navigationItem.title = user.screenname!
            if user.userID! == User.currentUser!.userID!{
                followButton.hidden = true
                self.navigationItem.title = "Me"
            }
            backgroundImageView.setImageWithURL(NSURL(string: user.profile_background_image_url_https!)!)
            profileImageView.setImageWithURL(NSURL(string:user.profileImageUrl!)!)
            screenNameLabel.text = user.screenname
            nameLabel.text = "@\(user.name!)"
            userDescription.text = user.userDescription
            followerCountLabel.text = String(user.followers_count!)
            followingCountLabel.text = String(user.following_count!)
            headerView.backgroundColor = hexStringToUIColor(user.profile_sidebar_fill_color!,alpha: 0.3)
            if let isfollowing = user.following{
                if (isfollowing){
                    followButton.setTitle("Unfollow", forState: .Normal)
                }else{
                    followButton.setTitle("Follow", forState: .Normal)
                }
            }else{
                print("is not defined")
            }
            
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets{
            return tweets.count
        }else{
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetTableViewCell
        let tweet = tweets![indexPath.row]
        cell.tweet = tweet
        cell.profileImage.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        cell.screenName.text = tweet.user!.screenname!
        cell.name.text = "@\(tweet.user!.name!)"
        cell.date.text = convertTimeToString(Int(NSDate().timeIntervalSinceDate(tweet.createdAt!)))
        cell.detailText.text = tweet.text
        cell.retweetCount.text = String(tweet.retweet_count!)
        cell.favorateCount.text = String(tweet.favorite_count!)
        
        
        let backgroundImage = UIImageView()
        if let url = tweet.user?.profile_background_image_url_https{
            backgroundImage.setImageWithURL(NSURL(string: url)!)
            backgroundImage.alpha = 0.2
        }
        cell.backgroundView = backgroundImage
        
        
        let retweetTapAction = UITapGestureRecognizer(target: self, action: "retweet:")
        cell.retweetImage.tag = indexPath.row
        cell.retweetImage.userInteractionEnabled = true
        cell.retweetImage.addGestureRecognizer(retweetTapAction)
        if tweet.hasRetweeted{
            cell.retweetImage.highlighted = true
        }
        
        
        let favorateTapAction = UITapGestureRecognizer(target: self, action: "favorate:")
        cell.favorateImage.tag = indexPath.row
        cell.favorateImage.userInteractionEnabled = true
        cell.favorateImage.addGestureRecognizer(favorateTapAction)
        if tweet.hasFavorated{
            cell.favorateImage.highlighted = true
        }
        
        let tweetTapAction = UITapGestureRecognizer(target: self, action: "tweetTap:")
        cell.userInteractionEnabled = true
        cell.tag = indexPath.row
        cell.addGestureRecognizer(tweetTapAction)
        
        cell.selectionStyle = .None
        
        return cell

    }
    func statusBarTappedAction(notification: NSNotification) {
        print("tap")
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: NSNotFound, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func followButtonClicked(sender: UIButton) {
        if let isfollowing = user?.following{
            if (isfollowing){
                TwitterClient.sharedInstance.unFollowUserWithParams(["user_id": user!.userID!], completion: { (response, error) -> () in
                    if (error == nil){
                        self.followButton.setTitle("Follow", forState: .Normal)
                        self.user!.following! = false
                    }else{
                        print(error)
                    }
                })
            }else{
                TwitterClient.sharedInstance.followUserWithParams(["user_id": user!.userID!], completion: { (response, error) -> () in
                    if (error == nil){
                        self.followButton.setTitle("Unfollow", forState: .Normal)
                        self.user!.following! = true
                    }else{
                        print(error)
                    }
                })
            }
        }else{
            print("is not defined")
        }

    }
    func retweet(sender: UITapGestureRecognizer){
        if sender.state != .Ended{
            return
        }
        
        let index = sender.view?.tag
        if let index = index{
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetTableViewCell
            if (!cell.tweet!.hasRetweeted){
                TwitterClient.sharedInstance.retweetWithTweetID(tweets![index].tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweets![index].retweet_count! += 1
                        self.tweets![index].hasRetweeted = true
                        cell.retweetCount.text = String(Int(cell.retweetCount.text!)! + 1)
                        cell.tweet!.hasRetweeted = true
                        cell.retweetImage.highlighted = true
                    }else{
                        print("Retweeted fail: \(error!.description)")
                    }
                })
            }else{
                TwitterClient.sharedInstance.unRetweetWithTweetID(tweets![index].tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweets![index].retweet_count! -= 1
                        self.tweets![index].hasRetweeted = false
                        cell.retweetCount.text = String(Int(cell.retweetCount.text!)! - 1)
                        cell.tweet!.hasRetweeted = false
                        cell.retweetImage.highlighted = false
                    }else{
                        print("Unretweeted fail: \(error!.description)")
                    }
                })
            }
        }
    }
    
    func favorate(sender: UITapGestureRecognizer){
        if sender.state != .Ended{
            return
        }
        let index = sender.view?.tag
        if let index = index{
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetTableViewCell
            if (!cell.tweet!.hasFavorated){
                TwitterClient.sharedInstance.favoratedWithTweetID(tweets![index].tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweets![index].favorite_count! += 1
                        self.tweets![index].hasFavorated = true
                        cell.favorateCount.text = String(Int(cell.favorateCount.text!)! + 1)
                        cell.tweet!.hasFavorated = true
                        cell.favorateImage.highlighted = true
                    }else{
                        print("favorated fail: \(error!.description)")
                    }
                })
            }else{
                TwitterClient.sharedInstance.unFavoratedWithTweetID(tweets![index].tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweets![index].favorite_count! -= 1
                        self.tweets![index].hasFavorated = false
                        cell.favorateCount.text = String(Int(cell.favorateCount.text!)! - 1)
                        cell.tweet!.hasFavorated = false
                        cell.favorateImage.highlighted = false
                    }else{
                        print("unfavorated fail: \(error!.description)")
                    }
                })
            }
        }
        
    }
    
    func tweetTap(sender: UITapGestureRecognizer){
        if sender.state != .Ended{
            return
        }
        let index = sender.view?.tag
        if let index = index{
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetTableViewCell
            self.performSegueWithIdentifier("DetailTweet", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? TweetTableViewCell {
            if let detailViewController = segue.destinationViewController as? DetailTweetViewController{
                detailViewController.tweet = tweets![tableView.indexPathForCell(cell)!.row]
                print("detail View")
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset <= 0{
            let newScale = 1.0 - (64 + offset) * (0.5/64)
            if newScale < 1.1{
                let transform = CGAffineTransformMakeScale(newScale, newScale)
                profileImageView.transform = transform
            }
        }else if offset >= 45{
            let newCenter: CGPoint = CGPointMake(0 + scrollView.contentOffset.x, -45 + scrollView.contentOffset.y)
            backgroundImageView.frame.origin = newCenter
            backgroundImageView.layer.zPosition = CGFloat(MAXFLOAT)
        }
        if offset <= -64.0{
            backgroundImageView.subviews.forEach({$0.removeFromSuperview()})
            let newScale = 1.0 - (64 + offset) * (2.0/290)
            let transform = CGAffineTransformMakeScale(newScale, newScale)
            backgroundImageView.frame.origin.y = (64 + offset)
            backgroundImageView.transform = transform
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            visualEffectView.frame = backgroundImageView.bounds
            visualEffectView.alpha = newScale - 1.0
            backgroundImageView.addSubview(visualEffectView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        backgroundImageView.subviews.forEach({$0.removeFromSuperview()})
        backgroundImageView.layer.zPosition = 0
    }
    
}
