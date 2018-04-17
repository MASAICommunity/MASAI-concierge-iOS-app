//
//  HotelSegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class HotelSegmentTableViewCell: JourneySegmentTableViewCell {
    
    internal override class var identifier: String { return "HotelSegmentTableViewCell" }
    
    private var segment: HotelSegment!
    
    override func setup(with segment: Segment) {
        guard let segment = segment as? HotelSegment else {
            assert(false, "Wrong segment passed!")
            return
        }
        
        self.segment = segment
        
        segmentTypeImageView.image = TypeImage.hotel.image
        titleLabel.text = "\(segment.cityName ?? "")"
        fillDateTime(from: segment.checkinDate)
        //TODO: how to fill in logo image view?
    }

}
