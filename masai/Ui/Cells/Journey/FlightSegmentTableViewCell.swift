//
//  FlightSegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class FlightSegmentTableViewCell: JourneySegmentTableViewCell {
    
    internal override class var identifier: String { return "FlightSegmentTableViewCell" }
    
    private var segment: FlightSegment!
    
    override func setup(with segment: Segment) {
        guard let segment = segment as? FlightSegment else {
            assert(false, "Wrong segment passed!")
            return
        }
        
        self.segment = segment
        
        segmentTypeImageView.image = TypeImage.flight.image
        titleLabel.text = "\(segment.originCityName ?? "") - \(segment.destinationCityName ?? "")"
        fillDateTime(from: segment.departureDatetime)
        //TODO: how to fill in logo image view?
    }

}
