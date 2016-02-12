//
//  TwitterClient.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

let twitterConsumerKey = "xnrAVCZstP1HgxVsN31URceTc"
let twitterConsumerSecret = "atVsvktSI3Xz4Vd3ijQwnz7ydG8mhV0ynxXHo8HNflzFD5MWkw"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")


class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?,error: NSError?) -> ())?
    
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?,error: NSError?) -> ()){
        loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken:BDBOAuth1Credential!) -> Void in
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            })
            { (error:NSError!) -> Void in
                self.loginCompletion!(user:nil,error: error)
        }
    }
    
    func openURL(url: NSURL){
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (access_token) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(access_token)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
                
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user,error:nil)
                
                }, failure: { (operation: NSURLSessionDataTask?, error:NSError) -> Void in
                    
                    self.loginCompletion?(user:nil,error: error)
                    
                })
            
            }) { (error: NSError!) -> Void in
                self.loginCompletion?(user:nil,error: error)
        }
        
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) ->()){
        
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            
                completion(tweets: tweets, error: nil)
            
            }, failure: { (operation: NSURLSessionDataTask?, error:NSError) -> Void in

                print("error getting current user\n\(error)")
                completion(tweets: nil, error: error)
            })
            
    }
    
    func retweetWithTweetID(tweetID: String,params: NSDictionary?, completion: (response: NSDictionary?,error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("1.1/statuses/retweet/\(tweetID).json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
                completion(response: response as? NSDictionary,error: nil)
            })
            { (operation: NSURLSessionDataTask?, error:NSError) -> Void in
                completion(response: nil,error: error)
            }
    }
    
    func unRetweetWithTweetID(tweetID: String,params: NSDictionary?, completion: (response: NSDictionary?,error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("1.1/statuses/unretweet/\(tweetID).json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
            completion(response: response as? NSDictionary,error: nil)
            })
            { (operation: NSURLSessionDataTask?, error:NSError) -> Void in
                completion(response: nil,error: error)
        }
    }
    
    func favoratedWithTweetID(tweetID: String,params: NSDictionary?, completion: (response: NSDictionary?,error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/favorites/create.json?id=\(tweetID)", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
            completion(response: response as? NSDictionary,error: nil)
            })
            { (operation: NSURLSessionDataTask?, error:NSError) -> Void in
                completion(response: nil,error: error)
        }
    }
    
    func unFavoratedWithTweetID(tweetID: String,params: NSDictionary?, completion: (response: NSDictionary?,error: NSError?) -> ()){
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/favorites/destroy.json?id=\(tweetID)", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject!) -> Void in
            completion(response: response as? NSDictionary,error: nil)
            })
            { (operation: NSURLSessionDataTask?, error:NSError) -> Void in
                completion(response: nil,error: error)
        }
    }
    
    

}
