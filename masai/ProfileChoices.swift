//
//  ProfileChoices.swift
//  masai
//
//  Created by Florian Rath on 23.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


struct ProfileChoice {
    typealias Title = String
    typealias Value = String
    
    let identifier: String
    let title: String
    var choices: [(Title, Value)] = []
    
    init(identifier: String, title: String) {
        self.identifier = identifier
        self.title = title
    }
}


struct ProfileChoices {
    
    // MARK: Types
    
    typealias RetrieveChoicesClosure = (_ choices: ProfileChoices?) -> Void
    typealias WillLoadFromBackendClosure = () -> Void
    
    
    // MARK: Properties
    
    var choiceDict: [String: ProfileChoice] = [:]
    
    private static var instance: ProfileChoices? = nil
    
    
    // MARK: Public
    
    var trainLoyaltyPrograms: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_loyalty_program"]?.choices ?? []
    }
    
    var carType: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_type"]?.choices ?? []
    }
    
    var airlineLoyaltyPrograms: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["airline_loyalty_program"]?.choices ?? []
    }
    
    var carExtras: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_extras"]?.choices ?? []
    }
    
    var flightOptions: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_options"]?.choices ?? []
    }
    
    var hotelChainsBlacklist: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_chains_blacklist"]?.choices ?? []
    }
    
    var flightBookingClassMediumHaul: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_booking_class_medium_haul"]?.choices ?? []
    }
    
    var passportCountryOfIssuance: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["passport_country_of_issuance"]?.choices ?? []
    }
    
    var flightMealPreference: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["flying_meal"]?.choices ?? []
    }
    
    var flightSeatRow: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["flying_seat_row"]?.choices ?? []
    }
    
    var carRentalCompanies: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_rental_companies"]?.choices ?? []
    }
    
    var flightSeat: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["flying_seat"]?.choices ?? []
    }
    
    var carPreferences: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_preferences"]?.choices ?? []
    }
    
    var hotelLocation: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_location"]?.choices ?? []
    }
    
    var hotelRoomStandards: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_room_standards"]?.choices ?? []
    }
    
    var flightAirlines: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_airlines"]?.choices ?? []
    }
    
    var hotelChains: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_chains"]?.choices ?? []
    }
    
    var hotelCategories: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_categories"]?.choices ?? []
    }
    
    var flightBookingClassLongHaul: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_booking_class_long_haul"]?.choices ?? []
    }
    
    var hotelTypes: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_types"]?.choices ?? []
    }
    
    var hotelRoomLocation: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_room_location"]?.choices ?? []
    }
    
    var hotelLoyaltyProgram: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_loyalty_program"]?.choices ?? []
    }
    
    var flightAirlinesBlacklist: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_airlines_blacklist"]?.choices ?? []
    }
    
    var carBookingClass: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_booking_class"]?.choices ?? []
    }
    
    var carLoyaltyPrograms: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["car_loyalty_program"]?.choices ?? []
    }
    
    var flightBookingClassShortHaul: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["plane_booking_class_short_haul"]?.choices ?? []
    }
    
    var hotelBedTypes: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_bed_types"]?.choices ?? []
    }
    
    var hotelAmenities: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["hotel_amenities"]?.choices ?? []
    }
    
    var trainTravelClass: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_travel_class"]?.choices ?? []
    }
    
    var trainCompartmentType: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_compartment_type"]?.choices ?? []
    }
    
    var trainSeatLocation: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_seat_location"]?.choices ?? []
    }
    
    var trainZone: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_zone"]?.choices ?? []
    }
    
    var trainPreferred: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_preferred"]?.choices ?? []
    }
    
    var trainSpecificBooking: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_specific_booking"]?.choices ?? []
    }
    
    var trainMobilityService: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_mobility_service"]?.choices ?? []
    }
    
    var trainTicket: [(ProfileChoice.Title, ProfileChoice.Value)] {
        return choiceDict["train_ticket"]?.choices ?? []
    }
    
    
    // MARK: Lifecycle
    
    static func from(json: [JSON]) -> ProfileChoices {
        
        let languageDescriptor: String
        switch LanguageHelper.currentLanguage {
        case .de:
            languageDescriptor = "DE"
        case .en:
            languageDescriptor = "EN"
        }
        
        let textDescriptor = "Text_\(languageDescriptor.uppercased())"
        
        var choices = ProfileChoices()
        
        for (_, item) in json.enumerated() {
            var choice = ProfileChoice(identifier: item["DataKey"]["S"].string!, title: item[textDescriptor]["S"].string!)
            for (_, jsonChoice):(String, JSON) in item["Choices"]["L"] {
                let val = jsonChoice["M"]["Value"]["S"].string!
                let text = jsonChoice["M"][textDescriptor]["S"].string!
                choice.choices.append((text, val))
            }
            
            choices.choiceDict[choice.identifier] = choice
        }
        
        return choices
    }
    
    static func retrieve(_ completion: @escaping RetrieveChoicesClosure, willLoadFromBackend: WillLoadFromBackendClosure? = nil) {
        if let instance = instance {
            completion(instance)
            return
        }
        
        willLoadFromBackend?()
        
        AwsBackendManager.getChoices { (didSucceed: Bool, choices: ProfileChoices?) in
            instance = choices
            completion(choices)
        }
    }
    
}
