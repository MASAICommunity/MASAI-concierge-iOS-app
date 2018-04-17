//
//  ChatMessageCollectionViewCell.swift
//  masai
//
//  Created by Bartłomiej Burzec on 08.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit


class OtherChatMessageCollectionViewCell: OtherAvatarBaseCollectionViewCell, ChatCell {

    static let identifier = "OtherChatMessageCollectionViewCell"
    static let textViewMargins = CGFloat(95.0)
    static let staticContentSize = CGFloat(38.0)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
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
        
        messageTextView.layer.cornerRadius = 15
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageTextView.backgroundColor = UIColor.chatMessageOrange
    }
    
    func setAsMarked(_ shouldMark: Bool) {
        if shouldMark {
            messageTextView.backgroundColor = UIColor.chatMessageGreen
        } else {
            messageTextView.backgroundColor = UIColor.chatMessageOrange
        }
    }
}
