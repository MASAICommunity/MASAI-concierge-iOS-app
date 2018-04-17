//
//  CarSegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class CarSegmentTableViewCell: JourneySegmentTableViewCell {
    
    internal override class var identifier: String { return "CarSegmentTableViewCell" }
    
    private var segment: CarSegment!
    
    override func setup(with segment: Segment) {
        guard let segment = segment as? CarSegment else {
            assert(false, "Wrong segment passed!")
            return
        }
        
        self.segment = segment
        
        segmentTypeImageView.image = TypeImage.car.image
        if segment.pickupCityName == segment.dropoffCityName {
            titleLabel.text = segment.pickupCityName
        } else {
            titleLabel.text = "\(segment.pickupCityName ?? "") - \(segment.dropoffCityName ?? "")"
        }
        fillDateTime(from: segment.pickupDatetime)
    }

}
