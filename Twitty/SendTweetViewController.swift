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
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textCountLabel.text = "Characters remained:  140"
        textView.layer.backgroundColor = UIColor.clearColor().CGColor
        textView.layer.borderColor = UIColor(red: 70/255.0, green: 154/255.0, blue: 233/255.0, alpha: 0.9).CGColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.becomeFirstResponder()
        self.automaticallyAdjustsScrollViewInsets = false
        textView.delegate = self
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar:Int = 140 - newLength
        textCountLabel.text = "Characters remained: \(remainingChar)"
        
        return (newLength < 140)
    }
    
    @IBAction func sendButtonClicked(sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.sendTweet(textView.text, params: nil) { (response, error) -> () in
            if (error == nil){
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                let alert = UIAlertController(title: nil, message: "Tweet Update Failed", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert,animated: true,completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
