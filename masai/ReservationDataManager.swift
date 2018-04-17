//
//  ReservationDataManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 01.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ReservationDataManager {
    
    static func reservationList() -> [ReservationBaseModel] {
        
        do {
            let filePath = Bundle.main.path(forResource: "journey", ofType: "json")
            let jsonString = try  NSString.init(contentsOfFile: filePath!, encoding: String.Encoding.utf8.rawValue)
            let json = JSON.init(parseJSON: jsonString as String)
            let jsonObjectArray = json["items"].arrayValue
            
            var reservations = [ReservationBaseModel]()
            
            for object in jsonObjectArray {
                if object["flight"].exists() {
                    var flight = Flight()
                    flight.update(object["flight"])
                    reservations.append(flight)
                } else if object["hotel-reservation"].exists() {
                    var hotel = Hotel()
                    hotel.update(object["hotel-reservation"])
                    reservations.append(hotel)
                } else if object["public-transportation"].exists() {
                    var publicTransport = PublicTransport()
                    publicTransport.update(object["public-transportation"])
                    reservations.append(publicTransport)
                } else if object["journey"].exists() {
                    for segment in object["segment"].arrayValue {
                        if segment["flight"].exists() {
                            var flight = Flight()
                            flight.update(segment["flight"])
                            reservations.append(flight)
                        } else if segment["hotel-reservation"].exists() {
                            var hotel = Hotel()
                            hotel.update(segment["hotel-reservation"])
                            reservations.append(hotel)
                        } else if segment["public-transportation"].exists() {
                            var publicTransport = PublicTransport()
                            publicTransport.update(segment["public-transportation"])
                            reservations.append(publicTransport)
                        }
                    }
                    
                }
            }
            return reservations
            
        } catch _ {
            return [ReservationBaseModel]()
        }
    }
}
