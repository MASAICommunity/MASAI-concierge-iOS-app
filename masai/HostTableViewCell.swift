//
//  HostTableViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 31.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class HostTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    
    static let identifier = "HostTableViewCell"
    static let defaultHeight: CGFloat = 70.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
