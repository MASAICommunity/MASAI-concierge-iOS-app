//
//  Notification+Post.swift
//  masai
//
//  Created by Florian Rath on 05.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class CloseChannelMessageCollectionViewCell: UICollectionViewCell, ChatCell {

    static let identifier = "CloseChannelMessageCollectionViewCell"
    
    static var message: String {
        return "channel_closed_text".localized
    }
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageLabel.text = CloseChannelMessageCollectionViewCell.message
    }

    static func calculateHeight(for chatMessage: ChatMessage) -> CGFloat {
        let labelFont = UIFont.systemFont(ofSize: 9, weight: UIFontWeightLight)
        let leftAndRightMargin = CGFloat(12)
        let totalHorizontalMargin = 2 * leftAndRightMargin
        let topAndBottomMargin = CGFloat(12)
        let totalVerticalMargin = 2 * topAndBottomMargin
        let totalHeight = UILabel.height(with: CloseChannelMessageCollectionViewCell.message, font: labelFont, width: UIScreen.main.bounds.size.width - totalHorizontalMargin) + totalVerticalMargin
        return totalHeight
    }
    
}
