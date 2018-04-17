//
//  PlaceAnnotationView.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotationView: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(lat: Double, long: Double) {
        self.coordinate = CLLocationCoordinate2DMake(lat, long)
    }
}
