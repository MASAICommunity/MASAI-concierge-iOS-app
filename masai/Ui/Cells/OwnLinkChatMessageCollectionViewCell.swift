//
//  OwnLinkChatMessageCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 22.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class OwnLinkChatMessageCollectionViewCell: UICollectionViewCell, ChatCell {

    static let staticContentWidth = CGFloat(240.0)
    static let staticImageHeight = CGFloat(150.0)
    static let verticalMargins = CGFloat(32.0)
    static let labelMargins = CGFloat(8.0)
    
    static let identifier = "OwnLinkChatMessageCollectionViewCell"
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var linkContentView: UIView!
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    @IBOutlet weak var linkHostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageStatusImageView: UIImageView!
    @IBOutlet weak var linkImageView: UIImageView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    
    
    weak var delegate: LinkMessageDelegate?
    var linkUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentWidthConstraint.constant = OwnLinkChatMessageCollectionViewCell.staticContentWidth
        self.imageViewHeightConstraint.constant = OwnLinkChatMessageCollectionViewCell.staticImageHeight
        
        self.linkContentView.layer.cornerRadius = 15.0
        
        self.linkContentView.layer.borderWidth = 0.3
        self.linkContentView.layer.borderColor = UIColor.borderGrey.cgColor
        
        self.layoutIfNeeded()
    }
    
    func messageTextViewVisible(_ visible: Bool) {
        if visible {
            self.messageTextView.removeConstraint(self.textViewHeightConstraint)
        } else if self.messageTextView.constraints.contains(self.textViewHeightConstraint) == false {
            self.messageTextView.addConstraint(self.textViewHeightConstraint)
        }
        self.layoutIfNeeded()
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
    
        let textHeight = UILabel.height(with: message.messageWithoutUrls, font: UIFont.systemFont(ofSize: 16), width: staticContentWidth - 2 * labelMargins)
        
        var titleLabelHeight = CGFloat(0)
        if let linkTitle = message.linkTitle {
            titleLabelHeight = UILabel.height(with: linkTitle, numberOfLines: 3, font: UIFont.systemFont(ofSize: 16), width: staticContentWidth - labelMargins)
        }
        var descriptionLabelHeight = CGFloat(0)
        if let descriptionText =  message.linkDescription {
            descriptionLabelHeight = UILabel.height(with: descriptionText, numberOfLines: 5, font: UIFont.systemFont(ofSize: 14), width: staticContentWidth - labelMargins)
        }
        var hostLabelHeight = CGFloat(0)
        if let hostText = message.linkHost {
            hostLabelHeight = UILabel.height(with: hostText, numberOfLines: 1, font: UIFont.systemFont(ofSize: 14), width: staticContentWidth - labelMargins)
        }
        
        return textHeight + titleLabelHeight + descriptionLabelHeight + hostLabelHeight + verticalMargins + staticImageHeight + labelMargins
    }
    
    @IBAction func onLinkButtonPressed(_ sender: Any) {
        if let url = self.linkUrl {
            delegate?.onLinkButtonPressed(url: url)
        }
    }

    
}
