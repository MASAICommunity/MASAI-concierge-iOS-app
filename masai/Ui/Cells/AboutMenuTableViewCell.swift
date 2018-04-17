//
//  AboutMenuTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 29.03.18.
//  Copyright © 2018 5lvlup gmbh. All rights reserved.
//

import UIKit

class AboutMenuTableViewCell: UITableViewCell {

    // MARK: UI
    
    @IBOutlet weak var label: UILabel!
    
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
