//
//  OtherAttachmentsChatMessageCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class OtherAttachmentsChatMessageCollectionViewCell: OtherAvatarBaseCollectionViewCell, ChatCell {

    static let identifier = "OtherAttachmentsChatMessageCollectionViewCell"
    
    static let verticalMargins = CGFloat(22.0)
    static let minimalHeight = CGFloat(80.0)
    static let attachmentViewWidth = CGFloat(50.0)
    static let containerViewWidth = CGFloat(260.0)
    static let textViewMargins = CGFloat(14.0)
    
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var attachmentLink: String?
    weak var delegate: AttachmentsMessageDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.attachmentViewWidthConstraint.constant = OtherAttachmentsChatMessageCollectionViewCell.attachmentViewWidth
        self.containerViewWidthConstraint.constant = OtherAttachmentsChatMessageCollectionViewCell.containerViewWidth
        self.fileNameLabel.text = "open".localized
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
         self.containerView.layer.cornerRadius = 15.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        if let messageText = message.attachmentDescription, let messageTitle = message.attachmentTitle {
            let mergedText = messageText + messageTitle
            let descriptionAttachmentHeight = UILabel.height(with: mergedText, numberOfLines: 0, font: UIFont.systemFont(ofSize: 16), width: containerViewWidth - attachmentViewWidth - textViewMargins)
            
            if descriptionAttachmentHeight > minimalHeight {
                return descriptionAttachmentHeight + textViewMargins + verticalMargins
            }
        }
        
        return minimalHeight + verticalMargins
    }
    
    
    @IBAction func onatachmentsButtonPressed(_ sender: Any) {
        if let link = self.attachmentLink {
            delegate?.onAttachmentsButtonPressed(link)
        }
    }
    

}
