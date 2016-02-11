//
//  TweetTableViewCell.swift
//  Twitty
//
//  Created by Juliang Li on 2/10/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var screenName: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var detailText: UITextView!
    
    
    @IBOutlet weak var retweetCount: UILabel!
    
    @IBOutlet weak var favorateCount: UILabel!
    
    @IBOutlet weak var retweetImage: UIImageView!
    
    @IBOutlet weak var favorateImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
