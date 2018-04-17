//
//  SingleGooglePlaceCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 08.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import Cosmos

class SingleGooglePlaceCollectionViewCell: UICollectionViewCell {

    static let identifier = "SingleGooglePlaceCollectionViewCell"
    
  
    @IBOutlet weak var placeContentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingStars: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var model: GooglePlace?
    weak var delegate: GooglePlaceDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onMapButtonPressed(_ sender: Any) {
        if let model = self.model {
            delegate?.onPressedMap(model)
        }
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        if let model = self.model {
            delegate?.onPressedSearch(model)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeContentView.layer.borderWidth = 0.5
        self.placeContentView.layer.borderColor = UIColor.init(white: 230/255, alpha: 1.0).cgColor
        self.placeContentView.layer.masksToBounds = true
    }
    
}
