//
//  DetailTweetViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/19/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class DetailTweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        self.navigationController?.navigationBar.topItem?.title = "";
        self.navigationItem.title = "Tweet"
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.backgroundColor = UIColor(red: 242.0 / 255.0, green: 246.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
        self.tableView.backgroundView = backgroundView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailUser", forIndexPath: indexPath) as! TweetDetailUserTableViewCell
            if let tweet = self.tweet{
                
                if let typeOfTweet = tweet.in_reply_to_screen_name{
                    cell.typeOfTweetLabel.text = "In reply to \(typeOfTweet)"
                }else if tweet.isRetweeted{
                    cell.typeOfTweetLabel.text = "\(tweet.user!.screenname!) retweeted"
                }else{
                    cell.typeOfTweetLabel.text = ""
                }
                
                cell.profileImageView.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
                cell.screenNameLabel.text = tweet.user!.screenname!
                cell.nameLabel.text = tweet.user!.name!
                cell.textView.text = tweet.text
                cell.CreatedAtLabel.text = tweet.createdAtString!
                if let media = tweet.mediaUrl{
                    let heightConstraint = NSLayoutConstraint(item: cell.mediaImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 200)
                    cell.contentView.addConstraint(heightConstraint)
                    cell.mediaImageView.setImageWithURL(NSURL(string: media)!)
                    
                }else{
                    cell.mediaImageView.hidden = true
                }
            }
            cell.selectionStyle = .None
            return cell
            
        }else if (indexPath.row == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailCount", forIndexPath: indexPath) as! TweetCountTableViewCell
            if let tweet = self.tweet{
                cell.retweetCountLabel.text = String(tweet.retweet_count!)
                cell.likesCount.text = String(tweet.favorite_count!)
            }
            cell.selectionStyle = .None

            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailAction", forIndexPath: indexPath) as! TweetActionTableViewCell
            if let tweet = self.tweet{
                let retweetTapAction = UITapGestureRecognizer(target: self, action: "retweet:")
                cell.retweetImage.tag = indexPath.row
                cell.retweetImage.userInteractionEnabled = true
                cell.retweetImage.addGestureRecognizer(retweetTapAction)
                if tweet.hasRetweeted{
                    cell.retweetImage.highlighted = true
                }
                
                
                let favorateTapAction = UITapGestureRecognizer(target: self, action: "favorate:")
                cell.likeImage.tag = indexPath.row
                cell.likeImage.userInteractionEnabled = true
                cell.likeImage.addGestureRecognizer(favorateTapAction)
                if tweet.hasFavorated{
                    cell.likeImage.highlighted = true
                }
                
                let replyTapAction = UITapGestureRecognizer(target: self, action: "reply:")
                cell.replyImage.userInteractionEnabled = true
                cell.replyImage.addGestureRecognizer(replyTapAction)
                
            }
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func retweet(sender: UITapGestureRecognizer){
        if sender.state != .Ended{
            return
        }
        
        let index = sender.view?.tag
        if let index = index{
            let actionCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetActionTableViewCell
            let countCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index-1, inSection: 0)) as! TweetCountTableViewCell
            if (!tweet!.hasRetweeted){
                TwitterClient.sharedInstance.retweetWithTweetID(tweet!.tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweet!.retweet_count! += 1
                        self.tweet!.hasRetweeted = true
                        countCell.retweetCountLabel.text = String(Int(countCell.retweetCountLabel.text!)! + 1)
                        self.tweet!.hasRetweeted = true
                        actionCell.retweetImage.highlighted = true
                    }else{
                        print("Retweeted fail: \(error!.description)")
                    }
                })
            }else{
                TwitterClient.sharedInstance.unRetweetWithTweetID(tweet!.tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweet!.retweet_count! -= 1
                        self.tweet!.hasRetweeted = false
                        countCell.retweetCountLabel.text = String(Int(countCell.retweetCountLabel.text!)! - 1)
                        self.tweet!.hasRetweeted = false
                        actionCell.retweetImage.highlighted = false
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
            let actionCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! TweetActionTableViewCell
            let countCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index-1, inSection: 0)) as! TweetCountTableViewCell
            if (!tweet!.hasFavorated){
                TwitterClient.sharedInstance.favoratedWithTweetID(tweet!.tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweet!.favorite_count! += 1
                        self.tweet!.hasFavorated = true
                        countCell.likesCount.text = String(Int(countCell.likesCount.text!)! + 1)
                        self.tweet!.hasFavorated = true
                        actionCell.likeImage.highlighted = true
                    }else{
                        print("favorated fail: \(error!.description)")
                    }
                })
            }else{
                TwitterClient.sharedInstance.unFavoratedWithTweetID(tweet!.tweetID!, params: nil, completion: { (response, error) -> () in
                    if (error == nil){
                        self.tweet!.favorite_count! -= 1
                        self.tweet!.hasFavorated = false
                        countCell.likesCount.text = String(Int(countCell.likesCount.text!)! - 1)
                        self.tweet!.hasFavorated = false
                        actionCell.likeImage.highlighted = false
                    }else{
                        print("unfavorated fail: \(error!.description)")
                    }
                })
            }
        }
        
    }
    
    func reply(sender: UITapGestureRecognizer){
        self.performSegueWithIdentifier("compose", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let composingViewController = segue.destinationViewController as? SendTweetViewController{
                composingViewController.defaultText = "@\(tweet!.user!.name!) "
        }
        
    }

}
