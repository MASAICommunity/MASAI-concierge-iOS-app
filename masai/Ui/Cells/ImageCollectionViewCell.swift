//
//  ImageCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 23.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate: class {
    func onImageViewPressed(_ imageView: UIImageView)
}


enum ImageCollectionViewCellType {
    case own, other
}


class ImageCollectionViewCell: OtherAvatarBaseCollectionViewCell, ChatCell {

    static let identifier = "ImageCollectionViewCell"
    static let horizontalStaticArea = CGFloat(78.0)
    static let verticalStaticArea = CGFloat(25.0)
    static let imageHeightRatio =  CGFloat(9.0/16.0)
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var messageStatusImgeView: UIImageView!
    @IBOutlet weak var messageStatusView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImageCollectionViewCellDelegate?
    
    var type: ImageCollectionViewCellType  = .own {
        didSet {
            onTypeUpdated()
        }
    }
    
    private func onTypeUpdated() {
        switch self.type {
        case .own:
            self.avatarView.isHidden = true
            self.messageStatusView.isHidden = false
            self.dateLabel.textAlignment = .right
        case .other:
            self.avatarView.isHidden = false
            self.messageStatusView.isHidden = true
            self.dateLabel.textAlignment = .left
            break
        }
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        return calculateHeight()
    }
    
    static func calculateHeight() -> CGFloat {
        let imageWidth = UIScreen.main.bounds.size.width - self.horizontalStaticArea
        let imageHeight = imageWidth * self.imageHeightRatio
        
        return self.verticalStaticArea + imageHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func onImageButtonPressed(_ sender: UIButton) {
        delegate?.onImageViewPressed(self.photoImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    

}
