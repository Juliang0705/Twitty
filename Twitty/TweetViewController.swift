//
//  TweetViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,SideBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView!
    var tweets:[Tweet]?
    var count = 20
    var sidebar:SideBar!
    var viewType = 1
    var searchTerm = ""
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTappedAction:", name: statusBarTappedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: statusBarTappedNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        TwitterClient.sharedInstance.homeTimelineWithParams(nil,completion: {
            (tweets,error) in
            self.tweets = tweets
            self.tableView.reloadData()
        });
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "bird"))
        navigationItem.leftBarButtonItem?.image = UIImage(named: "more")
        
        setupActivityView()
        sidebar = SideBar(sourceView: self.view, menuItems: ["Me","Home","Search","Log out"])
        sidebar.delegate = self
    }
    
    func sideBarDidSelectButtonAtIndex(index:Int){
        switch index{
        case 0:// me
            TwitterClient.sharedInstance.userTimelineWithParams(["user_id":User.currentUser!.userID!], completion: { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
                self.sidebar.showSideBar(false)
                self.viewType = 0
                self.count = 0
            })
            break
        case 1://home time line
        TwitterClient.sharedInstance.homeTimelineWithParams(nil,completion: {
            (tweets,error) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.sidebar.showSideBar(false)
            self.viewType = 1
            self.count = 0
        });
            break
        case 2://search
            print("search Clicked")
            self.sidebar.showSideBar(false)
            let alert = UIAlertController(title: "Search Tweets", message: "Enter terms", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            })
            alert.addAction(UIAlertAction(title: "Search", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                self.searchTerm = textField.text!
                TwitterClient.sharedInstance.searchTweetWithParams(["q":self.searchTerm],completion: {
                    (tweets,error) in
                    self.tweets = tweets
                    self.tableView.reloadData()
                    self.viewType = 2
                    self.count = 0
                })
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            break
        case 3://log out
            User.currentUser?.logout()
            break
        default:
            break
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets{
            return tweets.count
        }else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        cell.selectionStyle = .None
        
        return cell
    }
    func convertTimeToString(number: Int) -> String{
        let day = number/86400
        let hour = (number - day * 86400)/3600
        let minute = (number - day * 86400 - hour * 3600)/60
        if day != 0{
            return String(day) + "d"
        }else if hour != 0 {
            return String(hour) + "h"
        }else{
            return String(minute) + "m"
        }
    }
    
    
    func onRefresh(){
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        if viewType == 0{
            TwitterClient.sharedInstance.userTimelineWithParams(["user_id":User.currentUser!.userID!,"count":count],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
            });
            
        }else if viewType == 1{
            TwitterClient.sharedInstance.homeTimelineWithParams(["count":count],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
            });
        }else if viewType == 2{
            TwitterClient.sharedInstance.searchTweetWithParams(["q":self.searchTerm],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
            })
        }
        refreshControl.endRefreshing()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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
    
    
    func setupActivityView(){
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView.hidden = true
        tableView.addSubview(loadingMoreView)
        tableView.bringSubviewToFront(loadingMoreView)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                // Code to load more results
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView.frame = frame
                loadingMoreView.startAnimating()
                
                loadMoreData()
                
            }
            
        }
    }
    
    func loadMoreData(){
        if viewType == 0{
            if (count == 3200){
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
                return
            }
            count += 20
            TwitterClient.sharedInstance.userTimelineWithParams(["user_id":User.currentUser!.userID!,"count":count],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
            });
            
        }else if viewType == 1{
            if (count == 200){
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
                return
            }
            count += 20
            TwitterClient.sharedInstance.homeTimelineWithParams(["count":count],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
            });
        }else if viewType == 2{
            if (count == 200){
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
                return
            }
            count += 20
            TwitterClient.sharedInstance.searchTweetWithParams(["q":self.searchTerm,"count":count],completion: {
                (tweets,error) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.loadingMoreView.stopAnimating()
                self.isMoreDataLoading = false
            })
        }
    }
    
    func statusBarTappedAction(notification: NSNotification) {
        print("tap")
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: NSNotFound, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func moreButtonClicked(sender: UIBarButtonItem) {
        if sidebar.isSideBarOpen{
            sidebar.showSideBar(false)
        }else{
            sidebar.showSideBar(true)
        }
    }
    
//    @IBAction func LogoutClicked(sender: AnyObject) {
//        User.currentUser?.logout()
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
