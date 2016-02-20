//
//  TweetCountTableViewCell.swift
//  Twitty
//
//  Created by Juliang Li on 2/19/16.
//  Copyright © 2016 Juliang. All rights reserved.
//

import UIKit

class TweetCountTableViewCell: UITableViewCell {

    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likesCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
