//
//  GooglePlaceDelegate.swift
//  masai
//
//  Created by Bartomiej Burzec on 08.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

protocol GooglePlaceDelegate: class {
    func onPressedSearch(_ place: GooglePlace)
    func onPressedMap(_ place: GooglePlace)
}
