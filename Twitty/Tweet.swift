//
//  Tweet.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import Foundation

class Tweet: NSObject{
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var dictionary: NSDictionary
    // add my thing
    var favorite_count: Int?
    var favorited: Int?
    var retweet_count: Int?
    var retweeted: Bool?
    
    var tweetID: String?
    var hasRetweeted = false
    var hasFavorated = false
    var in_reply_to_screen_name: String?
    var mediaUrl: String?
    var isRetweeted = false
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        favorite_count = retweetedStatus != nil ? retweetedStatus!["favorite_count"] as? Int : dictionary["favorite_count"] as? Int
        favorited = dictionary["favorited"] as?Int
        retweet_count = dictionary["retweet_count"] as? Int
        retweeted = dictionary["retweeted"] as? Bool
        tweetID = dictionary["id_str"] as? String
        hasFavorated = dictionary["favorited"] as! Bool
        hasRetweeted = dictionary["retweeted"] as! Bool
        in_reply_to_screen_name = dictionary["in_reply_to_screen_name"] as? String
        //result->entities->media[0]->media_url;
        let entities = dictionary["entities"] as? NSDictionary
        let firstDictionary = (entities?["media"] as? [NSDictionary])?[0]
        mediaUrl = firstDictionary?["media_url_https"] as? String
        if dictionary["retweeted_status"] != nil{
            isRetweeted = true
        }
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in array{
            tweets.append(Tweet(dictionary: dictionary));
        }
        return tweets
    }
}