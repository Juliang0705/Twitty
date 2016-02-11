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
    var retweeted: Int?
    
    
    
    
    
    
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        favorite_count = dictionary["favorite_count"] as? Int
        favorited = dictionary["favorited"] as?Int
        retweet_count = dictionary["retweet_count"] as? Int
        retweeted = dictionary["retweeted"] as? Int
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in array{
            tweets.append(Tweet(dictionary: dictionary));
        }
        return tweets
    }
}