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
    
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
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