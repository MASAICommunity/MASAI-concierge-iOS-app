//
//  TimelineTableViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!

    static let identifier = "TimelineTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
    }
    
    
}
