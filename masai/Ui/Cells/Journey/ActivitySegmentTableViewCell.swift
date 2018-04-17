//
//  ActivitySegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit

class ActivitySegmentTableViewCell: JourneySegmentTableViewCell {
    
    internal override class var identifier: String { return "ActivitySegmentTableViewCell" }
    
    private var segment: ActivitySegment!
    
    override func setup(with segment: Segment) {
        guard let segment = segment as? ActivitySegment else {
            assert(false, "Wrong segment passed!")
            return
        }
        
        self.segment = segment
        
        segmentTypeImageView.image = TypeImage.activity.image
        titleLabel.text = "\(segment.activityName ?? "")"
        fillDateTime(from: segment.startDatetime)
    }

}
