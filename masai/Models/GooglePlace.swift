//
//  GooglePlace.swift
//  masai
//
//  Created by Bartomiej Burzec on 08.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

public class GooglePlace: BaseDatabaseModel {
    
    dynamic var lat: Double = 0.0
    dynamic var long: Double = 0.0
    dynamic var name: String?
    dynamic var rating: Double = 0.0
    dynamic var icon: String?
    dynamic var photoReference: String?
    dynamic var placeId: String?
    dynamic var type: String?
    dynamic var width: Int = 0
    
    func photoAddress() -> String {
        if let referece = self.photoReference {
            return Constants.Google.photoEndpoint + "&photoreference=" + referece + "&maxwidth=\(width)"
        }
        return ""
    }
}

extension GooglePlace: Updatable {
    func update(with json: JSON) {
        let location = json[Constants.Network.Json.geometry][Constants.Network.Json.location]
        self.lat = location[Constants.Network.Json.lat].doubleValue
        self.long = location[Constants.Network.Json.lng].doubleValue
        self.name = json[Constants.Network.Json.name].string
        self.rating = json[Constants.Network.Json.rating].doubleValue
        self.icon = json[Constants.Network.Json.icon].string
        self.photoReference = json[Constants.Network.Json.photos][0][Constants.Network.Json.photoReference].string
        self.width = json[Constants.Network.Json.photos][0][Constants.Network.Json.width].intValue
        self.placeId = json[Constants.Network.Json.placeId].string
        self.type = json[Constants.Network.Json.types][0].string
        
        if self.identifier == nil {
            self.identifier = json[Constants.Network.Json.id].string
        }
    }
}
