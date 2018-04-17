//
//  LocationMessageDelegate.swift
//  masai
//
//  Created by Bartomiej Burzec on 24.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import MapKit

protocol LocationMessageDelegate: class {
    func onMapPressed(_ location: CLLocationCoordinate2D)
}
