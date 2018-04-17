//
//  FlightTableViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {

    @IBOutlet weak var reservationView: UIView!
    
    @IBOutlet weak var departuesLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    
    static let identifier = "FlightTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.reservationView.layer.borderColor = UIColor.init(white: 230/255, alpha: 1.0).cgColor
        self.reservationView.layer.borderWidth = 0.5
    }
    
}
