//
//  TweetViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit
extension UIImage{
    func resizeImage(width width: CGFloat, height: CGFloat) -> UIImage {
        //UIGraphicsBeginImageContext(newSize);
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 0.0)
        self.drawInRect(CGRectMake(0, 0, width, height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

class TweetViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var tweets:[Tweet]?
    
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
        navigationItem.titleView = UIImageView(image: UIImage(named: "bird"))
        navigationItem.leftBarButtonItem?.image = UIImage(named: "more")
        
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
        cell.profileImage.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        cell.screenName.text = tweet.user!.screenname!
        cell.name.text = "@\(tweet.user!.name!)"
        cell.date.text = convertTimeToString(Int(NSDate().timeIntervalSinceDate(tweet.createdAt!)))
        cell.detailText.text = tweet.text
        cell.retweetCount.text = String(tweet.retweet_count!)
        cell.favorateCount.text = String(tweet.favorite_count!)
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
