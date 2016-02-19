//
//  UserViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/17/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

func hexStringToUIColor (hex:String) -> UIColor {
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
        alpha: CGFloat(1.0)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = self.user{
            backgroundImageView.setImageWithURL(NSURL(string: user.profile_background_image_url_https!)!)
            profileImageView.setImageWithURL(NSURL(string:user.profileImageUrl!)!)
            screenNameLabel.text = user.screenname
            nameLabel.text = user.name
            userDescription.text = user.userDescription
            followerCountLabel.text = String(user.followers_count)
            followingCountLabel.text = String(user.following_count)
            headerView.backgroundColor = hexStringToUIColor(user.profile_sidebar_fill_color!)
            headerView.alpha = 0.5
        }

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
        
        cell.selectionStyle = .None
        
        return cell

    }

}
