//
//  SendTweetViewController.swift
//  Twitty
//
//  Created by Juliang Li on 2/12/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class SendTweetViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var countLabel: UILabel?
    var defaultText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = defaultText
        setUpSendButtonAndTextCount()
        textView.layer.backgroundColor = UIColor.clearColor().CGColor
        textView.layer.borderColor = UIColor(red: 70/255.0, green: 154/255.0, blue: 233/255.0, alpha: 0.9).CGColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.becomeFirstResponder()
        self.automaticallyAdjustsScrollViewInsets = false
        textView.delegate = self
        self.navigationController?.navigationBar.topItem?.title = "";
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar:Int = 140 - newLength
        countLabel?.text = "\(remainingChar)"
        return (newLength < 140)
    }
    
    func sendButtonClicked(sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.sendTweet(textView.text, params: nil) { (tweet, error) -> () in
            if (error == nil){
                tweetViewControllerReference?.tweets?.insert(tweet!, atIndex: 0)
                self.navigationController?.popViewControllerAnimated(true)
                
            }else{
                let alert = UIAlertController(title: nil, message: "Tweet Update Failed", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert,animated: true,completion: nil)
            }
        }
    }
    
    func setUpSendButtonAndTextCount(){
        let textCountLabel = UIBarButtonItem(title: "140", style: .Plain, target: nil, action: nil)
        textCountLabel.enabled = false
        self.countLabel = UILabel(frame: CGRectMake(0,0,50,16))
        countLabel?.text = String(140 - textView.text.characters.count)
        countLabel?.sizeToFit()
        textCountLabel.customView = countLabel
        let sendButton = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: "sendButtonClicked:")
        self.navigationItem.rightBarButtonItems = [sendButton,textCountLabel]
        
        
    }

}
