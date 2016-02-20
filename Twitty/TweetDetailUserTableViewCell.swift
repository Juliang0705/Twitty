//
//  TweetDetailUserTableViewCell.swift
//  Twitty
//
//  Created by Juliang Li on 2/19/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class TweetDetailUserTableViewCell: UITableViewCell {

    @IBOutlet weak var typeOfTweetLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var CreatedAtLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
