//
//  ConversationTableViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
    
    static let identifier = "ConversationTableViewCell"
    static let defaultHeight: CGFloat = 70.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
