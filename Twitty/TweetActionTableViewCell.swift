//
//  TweetActionTableViewCell.swift
//  Twitty
//
//  Created by Juliang Li on 2/19/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class TweetActionTableViewCell: UITableViewCell {

    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var replyImage: UIImageView!
    
    @IBOutlet weak var retweetImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
