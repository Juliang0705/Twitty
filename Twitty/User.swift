//
//  User.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import Foundation

var _currentUser: User?

let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject{
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary
    //add my thing
    var favourites_count: Int?
    var followers_count: Int?
    var following_count: Int?
    var location: String?
    var profile_background_image_url_https: String?
    
    var userDescription: String?
    var profile_background_color: String?
    var profile_sidebar_border_color: String?
    var profile_sidebar_fill_color: String?
    var profile_text_color: String?
    var userID: String?
    var following: Bool?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        favourites_count = dictionary["favourites_count"] as? Int
        followers_count = dictionary["followers_count"] as? Int
        following_count = dictionary["friends_count"] as? Int
        location = dictionary["location"] as? String
        profile_background_image_url_https = dictionary["profile_background_image_url_https"] as? String
        userDescription = dictionary["description"] as? String
        profile_background_color = dictionary["profile_background_color"] as? String
        profile_sidebar_border_color = dictionary["profile_sidebar_border_color"] as? String
        profile_sidebar_fill_color = dictionary["profile_sidebar_fill_color"] as? String
        profile_text_color = dictionary["profile_text_color"] as? String
        userID = dictionary["id_str"] as? String
        following = dictionary["following"] as? Bool
    }
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User?{
        get{
        if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? NSData
        do{
        if data != nil{
        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue:0)) as! NSDictionary
        _currentUser = User(dictionary: dictionary)
    }
        else{
        
        }
    }catch{
        print("Error reading JSON")
        }
        
        }
        return _currentUser
        }
        set(user){
            _currentUser = user
            
            do {
                if _currentUser != nil {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions(rawValue:0))
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "currentUser")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                }else{
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "currentUser")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }catch {
                print("Error writing JSON")
            }
            
        }
    }
}