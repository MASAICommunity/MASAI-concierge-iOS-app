//
//  TrainSegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class TrainSegmentTableViewCell: JourneySegmentTableViewCell {
    
    internal override class var identifier: String { return "TrainSegmentTableViewCell" }
    
    private var segment: TrainSegment!
    
    override func setup(with segment: Segment) {
        guard let segment = segment as? TrainSegment else {
            assert(false, "Wrong segment passed!")
            return
        }
        
        self.segment = segment
        
        segmentTypeImageView.image = TypeImage.train.image
        titleLabel.text = "\(segment.originCityName ?? "") - \(segment.destinationCityName ?? "")"
        fillDateTime(from: segment.departureDatetime)
        //TODO: how to fill in logo image view?
    }

}
