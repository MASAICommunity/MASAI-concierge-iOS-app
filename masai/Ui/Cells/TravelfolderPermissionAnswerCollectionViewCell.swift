//
//  TravelfolderPermissionAnswerCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class TravelfolderPermissionAnswerCollectionViewCell: UICollectionViewCell, ChatCell {

    static let height = CGFloat(22.0)
  
    static let identifier = "TravelfolderPermissionAnswerCollectionViewCell"
    
     @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        return calculateHeight()
    }
    
    static func calculateHeight() -> CGFloat {
        return height
    }
    
    func access() {
        self.titleLabel.textColor = .accessGreen
        self.titleLabel.text = "travelFolderAccessGranted".localized
    }
    
    func denied() {
        self.titleLabel.textColor = .deniedRed
        self.titleLabel.text = "travelFolderAccessDenied".localized
    }
    
}
