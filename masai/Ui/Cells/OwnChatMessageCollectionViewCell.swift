//
//  OtherChatMessageCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class OwnChatMessageCollectionViewCell: UICollectionViewCell, ChatCell {

    static let identifier = "OwnChatMessageCollectionViewCell"
    static let textViewMargins = CGFloat(55.0)
    static let staticContentSize = CGFloat(35.0)
    
    @IBOutlet weak var messageStatusImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        layoutIfNeeded()
    }

    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        if let messageText = message.messageText {
            let totalHeight = UILabel.height(with: messageText, font: UIFont.systemFont(ofSize: 16), width: UIScreen.main.bounds.size.width - textViewMargins) + staticContentSize
            return totalHeight
        }
        
        return staticContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.messageTextView.layer.cornerRadius = 15
    }
    
    func setAsMarked(_ shouldMark: Bool) {
        if shouldMark {
            messageTextView.backgroundColor = UIColor.chatMessageGreen
        } else {
            messageTextView.backgroundColor = UIColor.chatMessageBlue
        }
    }
    
}
