//
//  TravelfolderPermissionCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class TravelfolderPermissionCollectionViewCell: UICollectionViewCell, ChatCell {

    static let identifier = "TravelfolderPermissionCollectionViewCell"
    
    static let height = CGFloat(22.0)
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = "request_folder_access_permission".localized
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        return calculateHeight()
    }
    
    static func calculateHeight() -> CGFloat {
        return height
    }

}
