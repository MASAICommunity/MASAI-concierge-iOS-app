//
//  ProfileTransformator.swift
//  masai
//
//  Created by Florian Rath on 18.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import SwiftyJSON


class ProfileTransformator {
    
    // MARK: Public
    
    static func transform(json baseJson: JSON) -> UserProfile {
        let profile = UserProfile()
        let json = baseJson["Items"][0]
        
        profile.awsUserId = json["UserId"]["S"].string
        
        let contact = json["contact"]["M"]
        profile.primaryEmailAddress = contact["primary_email"]["S"].string
        profile.primaryPhoneNumber = contact["primary_phone"]["S"].string
        
        let billing = json["address_billing"]["M"]
        profile.companyZip = billing["zip"]["S"].string
        profile.companyCountry = billing["country"]["S"].string
        profile.companyCity = billing["city"]["S"].string
        profile.companyAddressLine1 = billing["address_line_1"]["S"].string
        profile.companyAddressLine2 = billing["address_line_2"]["S"].string
        profile.companyState = billing["state"]["S"].string
        profile.companyName = billing["company_name"]["S"].string
        profile.companyVatId = billing["vat"]["S"].string
        
        let passport = json["passport"]["M"]
        profile.passportNumber = passport["number"]["S"].string
        profile.passportCountryOfIssuance = passport["country"]["S"].string
        profile.passportExpiryDate = passport["expiry"]["S"].string
        profile.passportCityOfIssuance = passport["city"]["S"].string
        profile.passportDateOfIssuance = passport["date_issued"]["S"].string
        
        let esta = json["esta"]["M"]
        profile.estaApplicationNumber = esta["application_number"]["S"].string
        profile.estaValidUntil = esta["valid_until"]["S"].string
        
        let preferences = json["preference"]["M"]
        
        let hotel = preferences["hotel"]["M"]
        profile.hotelRoomStandard = hotel["room_standards"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelAmenities = hotel["amenities"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelType = hotel["types"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelChains = hotel["chains"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelChainsBlacklist = hotel["chains_blacklist"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelLoyaltyPrograms = hotel["loyalty_program"]["L"].arrayValue.flatMap({ (json: JSON) in
            return LoyaltyProgramEntry(identifier: json["M"]["id"]["S"].string, value: json["M"]["number"]["S"].string)
        })
        profile.hotelRoomLocation = hotel["room_location"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelLocation = hotel["location"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelCategory = hotel["categories"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelBedType = hotel["bed_types"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.hotelLoyaltyValidUntil = hotel["loyalty_date"]["S"].string
        profile.hotelAnythingElse = hotel["anything_else"]["S"].string
        
        let flights = preferences["flights"]["M"]
        profile.flightPreferredSeat = flights["seat"]["S"].string
        profile.flightMealPreference = flights["meal"]["S"].string
        profile.flightBookingClassShortHaul = flights["booking_class_short_haul"]["S"].string
        profile.flightPreferredRow = flights["seat_row"]["S"].string
        profile.flightBookingClassLongHaul = flights["booking_class_long_haul"]["S"].string
        profile.flightAirlineBlacklist = flights["airlines_blacklist"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.flightOptions = flights["options"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.flightLoyaltyPrograms = flights["airline_loyalty_program"]["L"].arrayValue.flatMap({ (json: JSON) in
            return LoyaltyProgramEntry(identifier: json["M"]["id"]["S"].string, value: json["M"]["number"]["S"].string)
        })
        profile.flightBookingClassMediumHaul = flights["booking_class_medium_haul"]["S"].string
        profile.flightAirlines = flights["airlines"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.flightLoyaltyValidUntil = flights["loyalty_date"]["S"].string
        profile.flightAnythingElse = flights["anything_else"]["S"].string
        
        let car = preferences["car"]["M"]
        profile.carLoyaltyPrograms = car["loyalty_programs"]["L"].arrayValue.flatMap({ (json: JSON) in
            return LoyaltyProgramEntry(identifier: json["M"]["id"]["S"].string, value: json["M"]["number"]["S"].string)
        })
        profile.carPreferences = car["preferences"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.carBookingClass = car["booking_class"]["S"].string
        profile.carPreferredRentalCompanies = car["rental_companies"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.carExtras = car["extras"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.carLoyaltyValidUntil = car["loyalty_date"]["S"].string
        profile.carAnythingElse = car["anything_else"]["S"].string
        profile.carType = car["type"]["S"].string
        
        let train = preferences["train"]["M"]
        profile.trainTravelClass = train["travel_class"]["S"].string
        profile.trainCompartmentType = train["compartment_type"]["S"].string
        profile.trainSeatLocation = train["seat_location"]["S"].string
        profile.trainZone = train["zone"]["S"].string
        profile.trainPreferred = train["preferred_trains"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.trainSpecificBooking = train["train_specific_booking"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.trainMobilityService = train["mobility_service"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.trainTicket = train["ticket"]["L"].arrayValue.flatMap({ $0["S"].string })
        profile.trainLoyaltyPrograms = train["loyalty_programs"]["L"].arrayValue.flatMap({ (json: JSON) in
            return LoyaltyProgramEntry(identifier: json["M"]["id"]["S"].string, value: json["M"]["number"]["S"].string)
        })
        profile.trainLoyaltyValidUntil = train["loyalty_date"]["S"].string
        profile.trainAnythingElse = train["anything_else"]["S"].string
        
        let addressPrivate = json["address_private"]["M"]
        profile.keepBillingAndPrivateIdentical = addressPrivate["accountsame"]["BOOL"].boolValue
        profile.addressLine1 = addressPrivate["address_line_1"]["S"].string
        profile.zipCode = addressPrivate["zip"]["S"].string
        profile.country = addressPrivate["country"]["S"].string
        profile.addressLine2 = addressPrivate["address_line_2"]["S"].string
        profile.state = addressPrivate["state"]["S"].string
        profile.city = addressPrivate["city"]["S"].string
        
        let personal = json["personal"]["M"]
        profile.contactEmailAddress = personal["email"]["S"].string
        profile.lastName = personal["last_name"]["S"].string
        profile.title = personal["title"]["S"].string
        profile.middleName = personal["middle_name"]["S"].string
        profile.nationality = personal["nationality"]["S"].string
        profile.firstName = personal["first_name"]["S"].string
        profile.birthDate = personal["birth_date"]["S"].string
        
        profile.isDirty = false
        
        return profile
    }
    
    static func transform(user: User, profile: UserProfile) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        var billingDict: [String: Any] = [:]
        if let value = profile.companyZip, value.length > 0 {
            billingDict["zip"] = ["S": value]
        }
        if let value = profile.companyCountry, value.length > 0 {
            billingDict["country"] = ["S": value]
        }
        if let value = profile.companyCity, value.length > 0 {
            billingDict["city"] = ["S": value]
        }
        if let value = profile.companyAddressLine1, value.length > 0 {
            billingDict["address_line_1"] = ["S": value]
        }
        if let value = profile.companyAddressLine2, value.length > 0 {
            billingDict["address_line_2"] = ["S": value]
        }
        if let value = profile.companyState, value.length > 0 {
            billingDict["state"] = ["S": value]
        }
        if let value = profile.companyName, value.length > 0 {
            billingDict["company_name"] = ["S": value]
        }
        if let value = profile.companyVatId, value.length > 0 {
            billingDict["vat"] = ["S": value]
        }
        dict["address_billing"] = ["M": billingDict]
        
        var passportDict: [String: Any] = [:]
        if let value = profile.passportNumber, value.length > 0 {
            passportDict["number"] = ["S": value]
        }
        if let value = profile.passportCountryOfIssuance, value.length > 0 {
            passportDict["country"] = ["S": value]
        }
        if let value = profile.passportExpiryDate, value.length > 0 {
            passportDict["expiry"] = ["S": value]
        }
        if let value = profile.passportCityOfIssuance, value.length > 0 {
            passportDict["city"] = ["S": value]
        }
        if let value = profile.passportDateOfIssuance, value.length > 0 {
            passportDict["date_issued"] = ["S": value]
        }
        dict["passport"] = ["M": passportDict]
        
        var estaDict: [String: Any] = [:]
        if let value = profile.estaApplicationNumber, value.length > 0 {
            estaDict["application_number"] = ["S": value]
        }
        if let value = profile.estaValidUntil, value.length > 0 {
            estaDict["valid_until"] = ["S": value]
        }
        dict["esta"] = ["M": estaDict]
        
        var contactDict: [String: Any] = [:]
        if let value = profile.primaryEmailAddress, value.length > 0 {
            contactDict["primary_email"] = ["S": value]
        }
        if let value = profile.primaryPhoneNumber, value.length > 0 {
            contactDict["primary_phone"] = ["S": value]
        }
        dict["contact"] = ["M": contactDict]
        
        let roomStandards = transform(profile.hotelRoomStandard)
        let amenities = transform(profile.hotelAmenities)
        let types = transform(profile.hotelType)
        let chains = transform(profile.hotelChains)
        let chainsBlacklist = transform(profile.hotelChainsBlacklist)
        let loyaltyProgram = profile.hotelLoyaltyPrograms?.flatMap({ (entry) -> [String: Any]? in
            return ["M": ["number": ["S": entry.value], "id": ["S": entry.identifier]]]
        }) ?? []
        let roomLocation = transform(profile.hotelRoomLocation)
        let location = transform(profile.hotelLocation)
        let categories = transform(profile.hotelCategory)
        let bedTypes = transform(profile.hotelBedType)
        var hotelDict: [String: Any] = [:]
        hotelDict["room_standards"] = ["L": roomStandards]
        hotelDict["amenities"] = ["L": amenities]
        hotelDict["types"] = ["L": types]
        hotelDict["chains"] = ["L": chains]
        hotelDict["chains_blacklist"] = ["L": chainsBlacklist]
        hotelDict["loyalty_program"] = ["L": loyaltyProgram]
        hotelDict["room_location"] = ["L": roomLocation]
        hotelDict["location"] = ["L": location]
        hotelDict["categories"] = ["L": categories]
        hotelDict["bed_types"] = ["L": bedTypes]
        if let validUntil = profile.hotelLoyaltyValidUntil {
            hotelDict["loyalty_date"] = ["S": validUntil]
        }
        if let value = profile.hotelAnythingElse, value.length > 0 {
            hotelDict["anything_else"] = ["S": value]
        }
        let hotel = ["M": hotelDict]
        
        let airlinesBlacklist = transform(profile.flightAirlineBlacklist)
        let airlines = transform(profile.flightAirlines)
        let options = transform(profile.flightOptions)
        let airlineLoyaltyProgram = profile.flightLoyaltyPrograms?.flatMap({ (entry) -> [String: Any]? in
            return ["M": ["number": ["S": entry.value], "id": ["S": entry.identifier]]]
        }) ?? []
        var flightDict: [String: Any] = [:]
        if let value = profile.flightPreferredSeat, value.length > 0 {
            flightDict["seat"] = ["S": value]
        }
        if let value = profile.flightMealPreference, value.length > 0 {
            flightDict["meal"] = ["S": value]
        }
        if let value = profile.flightBookingClassShortHaul, value.length > 0 {
            flightDict["booking_class_short_haul"] = ["S": value]
        }
        if let value = profile.flightPreferredRow, value.length > 0 {
            flightDict["seat_row"] = ["S": value]
        }
        if let value = profile.flightBookingClassLongHaul, value.length > 0 {
            flightDict["booking_class_long_haul"] = ["S": value]
        }
        flightDict["airlines_blacklist"] = ["L": airlinesBlacklist]
        flightDict["options"] = ["L": options]
        flightDict["airline_loyalty_program"] = ["L": airlineLoyaltyProgram]
        if let value = profile.flightBookingClassMediumHaul, value.length > 0 {
            flightDict["booking_class_medium_haul"] = ["S": value]
        }
        flightDict["airlines"] = ["L": airlines]
        if let validUntil = profile.flightLoyaltyValidUntil {
            flightDict["loyalty_date"] = ["S": validUntil]
        }
        if let value = profile.flightAnythingElse, value.length > 0 {
            flightDict["anything_else"] = ["S": value]
        }
        let flights = ["M": flightDict]
        
        let carLoyaltyPrograms = profile.carLoyaltyPrograms?.flatMap({ (entry) -> [String: Any]? in
            return ["M": ["number": ["S": entry.value], "id": ["S": entry.identifier]]]
        }) ?? []
        let carPreferences = transform(profile.carPreferences)
        let carRentalCompanies = transform(profile.carPreferredRentalCompanies)
        let carExtras = transform(profile.carExtras)
        var carDict: [String: Any] = [:]
        carDict["loyalty_programs"] = ["L": carLoyaltyPrograms]
        carDict["preferences"] = ["L": carPreferences]
        if let value = profile.carBookingClass, value.length > 0 {
            carDict["booking_class"] = ["S": value]
        }
        carDict["rental_companies"] = ["L": carRentalCompanies]
        carDict["extras"] = ["L": carExtras]
        if let validUntil = profile.carLoyaltyValidUntil {
            carDict["loyalty_date"] = ["S": validUntil]
        }
        if let value = profile.carAnythingElse, value.length > 0 {
            carDict["anything_else"] = ["S": value]
        }
        if let value = profile.carType {
            carDict["type"] = ["S": value]
        }
        let car = ["M": carDict]
        
        let trainPreferred = transform(profile.trainPreferred)
        let trainSpecificBooking = transform(profile.trainSpecificBooking)
        let trainMobilityService = transform(profile.trainMobilityService)
        let trainTicket = transform(profile.trainTicket)
        let trainLoyaltyPrograms = profile.trainLoyaltyPrograms?.flatMap({ (entry) -> [String: Any]? in
            return ["M": ["number": ["S": entry.value], "id": ["S": entry.identifier]]]
        }) ?? []
        var trainDict: [String: Any] = [:]
        if let value = profile.trainTravelClass, value.length > 0 {
            trainDict["travel_class"] = ["S": value]
        }
        if let value = profile.trainCompartmentType, value.length > 0 {
            trainDict["compartment_type"] = ["S": value]
        }
        if let value = profile.trainSeatLocation, value.length > 0 {
            trainDict["seat_location"] = ["S": value]
        }
        if let value = profile.trainZone, value.length > 0 {
            trainDict["zone"] = ["S": value]
        }
        trainDict["preferred_trains"] = ["L": trainPreferred]
        trainDict["train_specific_booking"] = ["L": trainSpecificBooking]
        trainDict["mobility_service"] = ["L": trainMobilityService]
        trainDict["ticket"] = ["L": trainTicket]
        trainDict["loyalty_programs"] = ["L": trainLoyaltyPrograms]
        if let validUntil = profile.trainLoyaltyValidUntil {
            trainDict["loyalty_date"] = ["S": validUntil]
        }
        if let value = profile.trainAnythingElse, value.length > 0 {
            trainDict["anything_else"] = ["S": value]
        }
        let train = ["M": trainDict]
        
        dict["preference"] = [
            "M": [
                "hotel": hotel,
                "flights": flights,
                "car": car,
                "train": train,
            ]
        ]
        
        var addressDict: [String: Any] = [:]
        addressDict["accountsame"] = ["BOOL": profile.keepBillingAndPrivateIdentical]
        if let value = profile.addressLine1, value.length > 0 {
            addressDict["address_line_1"] = ["S": value]
        }
        if let value = profile.zipCode, value.length > 0 {
            addressDict["zip"] = ["S": value]
        }
        if let value = profile.country, value.length > 0 {
            addressDict["country"] = ["S": value]
        }
        if let value = profile.addressLine2, value.length > 0 {
            addressDict["address_line_2"] = ["S": value]
        }
        if let value = profile.state, value.length > 0 {
            addressDict["state"] = ["S": value]
        }
        if let value = profile.city, value.length > 0 {
            addressDict["city"] = ["S": value]
        }
        dict["address_private"] = ["M": addressDict]
        
        var personalDict: [String: Any] = [:]
        if let value = profile.contactEmailAddress, value.length > 0 {
            personalDict["email"] = ["S": value]
        }
        if let value = profile.lastName, value.length > 0 {
            personalDict["last_name"] = ["S": value]
        }
        if let value = profile.title, value.length > 0 {
            personalDict["title"] = ["S": value]
        }
        if let value = profile.middleName, value.length > 0 {
            personalDict["middle_name"] = ["S": value]
        }
        if let value = profile.nationality, value.length > 0 {
            personalDict["nationality"] = ["S": value]
        }
        if let value = profile.firstName, value.length > 0 {
            personalDict["first_name"] = ["S": value]
        }
        if let value = profile.birthDate, value.length > 0 {
            personalDict["birth_date"] = ["S": value]
        }
        dict["personal"] = ["M": personalDict]
        
        return dict
    }
    
    
    // MARK: Private
    
    static private func transform(_ array: [String]?) -> [[String: String]] {
        guard let array = array else {
            return []
        }
        
        var retVal: [[String: String]] = []
        for str in array {
            retVal.append(["S": str])
        }
        return retVal
    }
    
}
