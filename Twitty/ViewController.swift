//
//  ViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/8/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: UIButton) {
        TwitterClient.sharedInstance.loginWithCompletion(){
            (user: User?,error: NSError?) in
            if user != nil{
                print(user!.name!)
                self.performSegueWithIdentifier("login", sender: self)
            }else{
                print ("login error")
            }
        }
        
    }
}

