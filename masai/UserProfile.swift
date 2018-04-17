//
//  UserProfile.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Pantry
import SwiftyJSON


struct LoyaltyProgramEntry {
    
    // MARK: Properties
    
    var identifier: String?
    var value: String?
    private static var separator = "§"
    
    
    // MARK: Pantry
    
    init(identifier: String?, value: String?) {
        self.identifier = identifier
        self.value = value
    }
    
    func toString() -> String {
        var string = ""
        
        if let value = identifier {
            string += value
        }
        
        string += LoyaltyProgramEntry.separator
        
        if let val = value {
            string += val
        }
        
        return string
    }
    
    static func from(string: String?) -> LoyaltyProgramEntry? {
        guard let str = string else {
            return nil
        }
        
        let strComps = str.components(separatedBy: CharacterSet(charactersIn: LoyaltyProgramEntry.separator))
        
        var identifier: String? = nil
        if strComps.indices.contains(0) {
            identifier = strComps[0]
        }
        
        var value: String? = nil
        if strComps.indices.contains(1) {
            value = strComps[1]
        }
        
        return LoyaltyProgramEntry(identifier: identifier, value: value)
    }
    
}


extension Sequence where Iterator.Element == LoyaltyProgramEntry {
    
    func toString() -> String {
        let string = self.map({ $0.toString() }).joined(separator: "°")
        return string
    }
    
    static func from(string: String?) -> [LoyaltyProgramEntry]? {
        guard let str = string else {
            return nil
        }
        
        let strComps = str.components(separatedBy: CharacterSet(charactersIn: "°"))
        
        var items: [LoyaltyProgramEntry] = []
        for subStr in strComps {
            if let loyaltyProgramEntry = LoyaltyProgramEntry.from(string: subStr) {
                items.append(loyaltyProgramEntry)
            }
        }
        return items
    }
    
}


class UserProfile: Storable {
    
    // MARK: Properties
    
    var awsUserId: String?
    var isDirty = false {
        didSet {
//            print("is dirty: \(isDirty ? "yes" : "no")")
        }
    }
    
    // Personal data
    var title: String? {
        didSet {
            isDirty = true
        }
    }
    var firstName: String? {
        didSet {
            isDirty = true
        }
    }
    var middleName: String? {
        didSet {
            isDirty = true
        }
    }
    var lastName: String? {
        didSet {
            isDirty = true
        }
    }
    var nationality: String? {
        didSet {
            isDirty = true
        }
    }
    var birthDate: String? {
        didSet {
            isDirty = true
        }
    }
    
    var addressLine1: String? {
        didSet {
            isDirty = true
        }
    }
    var addressLine2: String? {
        didSet {
            isDirty = true
        }
    }
    var city: String? {
        didSet {
            isDirty = true
        }
    }
    var state: String? {
        didSet {
            isDirty = true
        }
    }
    var zipCode: String? {
        didSet {
            isDirty = true
        }
    }
    var country: String? {
        didSet {
            isDirty = true
        }
    }
    
    var contactEmailAddress: String? {
        didSet {
            isDirty = true
        }
    }
    var primaryEmailAddress: String? {
        didSet {
            isDirty = true
        }
    }
    var primaryPhoneNumber: String? {
        didSet {
            isDirty = true
        }
    }
    
    var keepBillingAndPrivateIdentical: Bool = false {
        didSet {
            isDirty = true
        }
    }
    
    var companyName: String? {
        didSet {
            isDirty = true
        }
    }
    private var _companyAddressLine1: String?
    var companyAddressLine1: String? {
        set {
            if _companyAddressLine1 != newValue {
                _companyAddressLine1 = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return addressLine1
            }
            return _companyAddressLine1
        }
    }
    private var _companyAddressLine2: String?
    var companyAddressLine2: String? {
        set {
            if _companyAddressLine2 != newValue {
                _companyAddressLine2 = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return addressLine2
            }
            return _companyAddressLine2
        }
    }
    private var _companyCity: String?
    var companyCity: String? {
        set {
            if _companyCity != newValue {
                _companyCity = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return city
            }
            return _companyCity
        }
    }
    private var _companyState: String?
    var companyState: String? {
        set {
            if _companyState != newValue {
                _companyState = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return state
            }
            return _companyState
        }
    }
    private var _companyZip: String?
    var companyZip: String? {
        set {
            if _companyZip != newValue {
                _companyZip = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return zipCode
            }
            return _companyZip
        }
    }
    private var _companyCountry: String?
    var companyCountry: String? {
        set {
            if _companyCountry != newValue {
                _companyCountry = newValue
                isDirty = true
            }
        }
        get {
            if keepBillingAndPrivateIdentical {
                return country
            }
            return _companyCountry
        }
    }
    var companyVatId: String? {
        didSet {
            isDirty = true
        }
    }
    
    // Travel preferences
    var passportNumber: String? {
        didSet {
            isDirty = true
        }
    }
    var passportCountryOfIssuance: String? {
        didSet {
            isDirty = true
        }
    }
    var passportCityOfIssuance: String? {
        didSet {
            isDirty = true
        }
    }
    var passportDateOfIssuance: String? {
        didSet {
            isDirty = true
        }
    }
    var passportExpiryDate: String? {
        didSet {
            isDirty = true
        }
    }
    
    var estaApplicationNumber: String? {
        didSet {
            isDirty = true
        }
    }
    var estaValidUntil: String? {
        didSet {
            isDirty = true
        }
    }
    
    var hotelCategory: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelType: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelLocation: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelBedType: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelRoomStandard: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelRoomLocation: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelAmenities: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelChains: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelChainsBlacklist: [String]? {
        didSet {
            isDirty = true
        }
    }
    var hotelLoyaltyPrograms: [LoyaltyProgramEntry]? {
        didSet {
            hotelLoyaltyPrograms = hotelLoyaltyPrograms?.filter({ (entry) -> Bool in
                if let identifier = entry.identifier,
                    identifier.length > 0,
                    let value = entry.value,
                    value.length > 0 {
                    return true
                }
                return false
            }) ?? nil
            isDirty = true
        }
    }
    var hotelLoyaltyValidUntil: String? {
        didSet {
            isDirty = true
        }
    }
    var hotelAnythingElse: String? {
        didSet {
            isDirty = true
        }
    }
    
    var flightBookingClassShortHaul: String? {
        didSet {
            isDirty = true
        }
    }
    var flightBookingClassMediumHaul: String? {
        didSet {
            isDirty = true
        }
    }
    var flightBookingClassLongHaul: String? {
        didSet {
            isDirty = true
        }
    }
    var flightPreferredSeat: String? {
        didSet {
            isDirty = true
        }
    }
    var flightPreferredRow: String? {
        didSet {
            isDirty = true
        }
    }
    var flightMealPreference: String? {
        didSet {
            isDirty = true
        }
    }
    var flightOptions: [String]? {
        didSet {
            isDirty = true
        }
    }
    var flightAirlines: [String]? {
        didSet {
            isDirty = true
        }
    }
    var flightAirlineBlacklist: [String]? {
        didSet {
            isDirty = true
        }
    }
    var flightLoyaltyPrograms: [LoyaltyProgramEntry]? {
        didSet {
            flightLoyaltyPrograms = flightLoyaltyPrograms?.filter({ (entry) -> Bool in
                if let identifier = entry.identifier,
                    identifier.length > 0,
                    let value = entry.value,
                    value.length > 0 {
                    return true
                }
                return false
            }) ?? nil
            isDirty = true
        }
    }
    var flightLoyaltyValidUntil: String? {
        didSet {
            isDirty = true
        }
    }
    var flightAnythingElse: String? {
        didSet {
            isDirty = true
        }
    }
    
    var carBookingClass: String? {
        didSet {
            isDirty = true
        }
    }
    var carType: String? {
        didSet {
            isDirty = true
        }
    }
    var carPreferences: [String]? {
        didSet {
            isDirty = true
        }
    }
    var carExtras: [String]? {
        didSet {
            isDirty = true
        }
    }
    var carPreferredRentalCompanies: [String]? {
        didSet {
            isDirty = true
        }
    }
    var carLoyaltyPrograms: [LoyaltyProgramEntry]? {
        didSet {
            carLoyaltyPrograms = carLoyaltyPrograms?.filter({ (entry) -> Bool in
                if let identifier = entry.identifier,
                    identifier.length > 0,
                    let value = entry.value,
                    value.length > 0 {
                    return true
                }
                return false
            }) ?? nil
            isDirty = true
        }
    }
    var carLoyaltyValidUntil: String? {
        didSet {
            isDirty = true
        }
    }
    var carAnythingElse: String? {
        didSet {
            isDirty = true
        }
    }
    
    var trainTravelClass: String? {
        didSet {
            isDirty = true
        }
    }
    var trainCompartmentType: String? {
        didSet {
            isDirty = true
        }
    }
    var trainSeatLocation: String? {
        didSet {
            isDirty = true
        }
    }
    var trainZone: String? {
        didSet {
            isDirty = true
        }
    }
    var trainPreferred: [String]? {
        didSet {
            isDirty = true
        }
    }
    var trainSpecificBooking: [String]? {
        didSet {
            isDirty = true
        }
    }
    var trainMobilityService: [String]? {
        didSet {
            isDirty = true
        }
    }
    var trainTicket: [String]? {
        didSet {
            isDirty = true
        }
    }
    var trainLoyaltyPrograms: [LoyaltyProgramEntry]? {
        didSet {
            trainLoyaltyPrograms = trainLoyaltyPrograms?.filter({ (entry) -> Bool in
                if let identifier = entry.identifier,
                    identifier.length > 0,
                    let value = entry.value,
                    value.length > 0 {
                    return true
                }
                return false
            }) ?? nil
            isDirty = true
        }
    }
    var trainLoyaltyValidUntil: String? {
        didSet {
            isDirty = true
        }
    }
    var trainAnythingElse: String? {
        didSet {
            isDirty = true
        }
    }
    
    
    // MARK: Lifecycle
    
    init() {}
    
    
    // MARK: Pantry
    
    required init?(warehouse: Warehouseable) {
        isDirty = warehouse.get("isDirty") ?? false
        
        let actualDirtyValue = isDirty
        
        awsUserId = warehouse.get("awsUserId")
        
        // Personal data
        title = warehouse.get("title")
        firstName = warehouse.get("firstName")
        middleName = warehouse.get("middleName")
        lastName = warehouse.get("lastName")
        nationality = warehouse.get("nationality")
        birthDate = warehouse.get("birthDate")
        
        addressLine1 = warehouse.get("addressLine1")
        addressLine2 = warehouse.get("addressLine2")
        city = warehouse.get("city")
        state = warehouse.get("state")
        zipCode = warehouse.get("zipCode")
        country = warehouse.get("country")
        
        contactEmailAddress = warehouse.get("contactEmailAddress")
        primaryEmailAddress = warehouse.get("primaryEmailAddress")
        primaryPhoneNumber = warehouse.get("primaryPhoneNumber")
        
        keepBillingAndPrivateIdentical = warehouse.get("keepBillingAndPrivateIdentical") ?? false
        
        companyName = warehouse.get("companyName")
        companyAddressLine1 = warehouse.get("companyAddressLine1")
        companyAddressLine2 = warehouse.get("companyAddressLine2")
        companyCity = warehouse.get("companyCity")
        companyState = warehouse.get("companyState")
        companyZip = warehouse.get("companyZip")
        companyCountry = warehouse.get("companyCountry")
        companyVatId = warehouse.get("companyVatId")
        
        // Travel preferences
        passportNumber = warehouse.get("passportNumber")
        passportCountryOfIssuance = warehouse.get("passportCountryOfIssuance")
        passportCityOfIssuance = warehouse.get("passportCityOfIssuance")
        passportDateOfIssuance = warehouse.get("passportDateOfIssuance")
        passportExpiryDate = warehouse.get("passportExpiryDate")
        
        estaApplicationNumber = warehouse.get("estaApplicationNumber")
        estaValidUntil = warehouse.get("estaValidUntil")
        
        hotelCategory = warehouse.get("hotelCategory")
        hotelType = warehouse.get("hotelType")
        hotelLocation = warehouse.get("hotelLocation")
        hotelBedType = warehouse.get("hotelBedType")
        hotelRoomStandard = warehouse.get("hotelRoomStandard")
        hotelRoomLocation = warehouse.get("hotelRoomLocation")
        hotelAmenities = warehouse.get("hotelAmenities")
        hotelChains = warehouse.get("hotelChains")
        hotelChainsBlacklist = warehouse.get("hotelChainsBlacklist")
        hotelLoyaltyPrograms = [LoyaltyProgramEntry].from(string: warehouse.get("hotelLoyaltyPrograms"))
        hotelLoyaltyPrograms = hotelLoyaltyPrograms?.filter({ (entry) -> Bool in
            if let identifier = entry.identifier,
                identifier.length > 0,
                let value = entry.value,
                value.length > 0 {
                return true
            }
            return false
        }) ?? nil
        hotelLoyaltyValidUntil = warehouse.get(PantryConstants.hotelLoyaltyValidUntil.rawValue)
        hotelAnythingElse = warehouse.get("hotelAnythingElse")
        
        flightBookingClassShortHaul = warehouse.get("flightBookingClassShortHaul")
        flightBookingClassMediumHaul = warehouse.get("flightBookingClassMediumHaul")
        flightBookingClassLongHaul = warehouse.get("flightBookingClassLongHaul")
        flightPreferredSeat = warehouse.get("flightPreferredSeat")
        flightPreferredRow = warehouse.get("flightPreferredRow")
        flightMealPreference = warehouse.get("flightMealPreference")
        flightOptions = warehouse.get("flightOptions")
        flightAirlines = warehouse.get("flightAirlines")
        flightAirlineBlacklist = warehouse.get("flightAirlineBlacklist")
        flightLoyaltyPrograms = [LoyaltyProgramEntry].from(string: warehouse.get("flightLoyaltyPrograms"))
        flightLoyaltyPrograms = flightLoyaltyPrograms?.filter({ (entry) -> Bool in
            if let identifier = entry.identifier,
                identifier.length > 0,
                let value = entry.value,
                value.length > 0 {
                return true
            }
            return false
        }) ?? nil
        flightLoyaltyValidUntil = warehouse.get(PantryConstants.flightLoyaltyValidUntil.rawValue)
        flightAnythingElse = warehouse.get("flightAnythingElse")
        
        carBookingClass = warehouse.get("carBookingClass")
        carType = warehouse.get("carType")
        carPreferences = warehouse.get("carPreferences")
        carExtras = warehouse.get("carExtras")
        carPreferredRentalCompanies = warehouse.get("carPreferredRentalCompanies")
        carLoyaltyPrograms = [LoyaltyProgramEntry].from(string: warehouse.get("carLoyaltyPrograms"))
        carLoyaltyPrograms = carLoyaltyPrograms?.filter({ (entry) -> Bool in
            if let identifier = entry.identifier,
                identifier.length > 0,
                let value = entry.value,
                value.length > 0 {
                return true
            }
            return false
        }) ?? nil
        carLoyaltyValidUntil = warehouse.get(PantryConstants.carLoyaltyValidUntil.rawValue)
        carAnythingElse = warehouse.get("carAnythingElse")
        
        trainTravelClass = warehouse.get("trainTravelClass")
        trainCompartmentType = warehouse.get("trainCompartmentType")
        trainSeatLocation = warehouse.get("trainSeatLocation")
        trainZone = warehouse.get("trainZone")
        trainPreferred = warehouse.get("trainPreferred")
        trainSpecificBooking = warehouse.get("trainSpecificBooking")
        trainMobilityService = warehouse.get("trainMobilityService")
        trainTicket = warehouse.get("trainTicket")
        trainLoyaltyPrograms = [LoyaltyProgramEntry].from(string: warehouse.get("trainLoyaltyPrograms"))
        trainLoyaltyPrograms = trainLoyaltyPrograms?.filter({ (entry) -> Bool in
            if let identifier = entry.identifier,
                identifier.length > 0,
                let value = entry.value,
                value.length > 0 {
                return true
            }
            return false
        }) ?? nil
        trainLoyaltyValidUntil = warehouse.get(PantryConstants.trainLoyaltyValidUntil.rawValue)
        trainAnythingElse = warehouse.get("trainAnythingElse")
        
        isDirty = actualDirtyValue
    }
    
    func toDictionary() -> [String : Any] {
        var dictionary: [String : Any] = [:]
        
        if let value = awsUserId {
            dictionary["awsUserId"] = value
        }
        
        dictionary["isDirty"] = isDirty
        
        // Personal data
        if let value = title {
            dictionary["title"] = value
        }
        
        if let value = firstName {
            dictionary["firstName"] = value
        }
        
        if let value = middleName {
            dictionary["middleName"] = value
        }
        
        if let value = lastName {
            dictionary["lastName"] = value
        }
        
        if let value = nationality {
            dictionary["nationality"] = value
        }
        
        if let value = birthDate {
            dictionary["birthDate"] = value
        }
        
        if let value = addressLine1 {
            dictionary["addressLine1"] = value
        }
        
        if let value = addressLine2 {
            dictionary["addressLine2"] = value
        }
        
        if let value = city {
            dictionary["city"] = value
        }
        
        if let value = state {
            dictionary["state"] = value
        }
        
        if let value = zipCode {
            dictionary["zipCode"] = value
        }
        
        if let value = country {
            dictionary["country"] = value
        }
        
        if let value = contactEmailAddress {
            dictionary["contactEmailAddress"] = value
        }
        
        if let value = primaryEmailAddress {
            dictionary["primaryEmailAddress"] = value
        }
        
        if let value = primaryPhoneNumber {
            dictionary["primaryPhoneNumber"] = value
        }
        
        dictionary["keepBillingAndPrivateIdentical"] = keepBillingAndPrivateIdentical
        
        if let value = companyName {
            dictionary["companyName"] = value
        }
        
        if let value = companyAddressLine1 {
            dictionary["companyAddressLine1"] = value
        }
        
        if let value = companyAddressLine2 {
            dictionary["companyAddressLine2"] = value
        }
        
        if let value = companyCity {
            dictionary["companyCity"] = value
        }
        
        if let value = companyState {
            dictionary["companyState"] = value
        }
        
        if let value = companyZip {
            dictionary["companyZip"] = value
        }
        
        if let value = companyCountry {
            dictionary["companyCountry"] = value
        }
        
        if let value = companyVatId {
            dictionary["companyVatId"] = value
        }
        
        // Travel preferences
        if let value = passportNumber {
            dictionary["passportNumber"] = value
        }
        
        if let value = passportCountryOfIssuance {
            dictionary["passportCountryOfIssuance"] = value
        }
        
        if let value = passportCityOfIssuance {
            dictionary["passportCityOfIssuance"] = value
        }
        
        if let value = passportDateOfIssuance {
            dictionary["passportDateOfIssuance"] = value
        }
        
        if let value = passportExpiryDate {
            dictionary["passportExpiryDate"] = value
        }
        
        if let value = estaApplicationNumber {
            dictionary["estaApplicationNumber"] = value
        }
        
        if let value = estaValidUntil {
            dictionary["estaValidUntil"] = value
        }
        
        if let value = hotelCategory {
            dictionary["hotelCategory"] = value
        }
        
        if let value = hotelType {
            dictionary["hotelType"] = value
        }
        
        if let value = hotelLocation {
            dictionary["hotelLocation"] = value
        }
        
        if let value = hotelBedType {
            dictionary["hotelBedType"] = value
        }
        
        if let value = hotelRoomStandard {
            dictionary["hotelRoomStandard"] = value
        }
        
        if let value = hotelRoomLocation {
            dictionary["hotelRoomLocation"] = value
        }
        
        if let value = hotelAmenities {
            dictionary["hotelAmenities"] = value
        }
        
        if let value = hotelChains {
            dictionary["hotelChains"] = value
        }
        
        if let value = hotelChainsBlacklist {
            dictionary["hotelChainsBlacklist"] = value
        }
        
        if let value = hotelLoyaltyPrograms {
            dictionary["hotelLoyaltyPrograms"] = value.toString()
        }
        
        if let value = hotelLoyaltyValidUntil {
            dictionary[PantryConstants.hotelLoyaltyValidUntil.rawValue] = value
        }
        
        if let value = hotelAnythingElse {
            dictionary["hotelAnythingElse"] = value
        }
        
        if let value = flightBookingClassShortHaul {
            dictionary["flightBookingClassShortHaul"] = value
        }
        
        if let value = flightBookingClassMediumHaul {
            dictionary["flightBookingClassMediumHaul"] = value
        }
        
        if let value = flightBookingClassLongHaul {
            dictionary["flightBookingClassLongHaul"] = value
        }
        
        if let value = flightPreferredSeat {
            dictionary["flightPreferredSeat"] = value
        }
        
        if let value = flightPreferredRow {
            dictionary["flightPreferredRow"] = value
        }
        
        if let value = flightMealPreference {
            dictionary["flightMealPreference"] = value
        }
        
        if let value = flightOptions {
            dictionary["flightOptions"] = value
        }
        
        if let value = flightAirlines {
            dictionary["flightAirlines"] = value
        }
        
        if let value = flightAirlineBlacklist {
            dictionary["flightAirlineBlacklist"] = value
        }
        
        if let value = flightLoyaltyPrograms {
            dictionary["flightLoyaltyPrograms"] = value.toString()
        }
        
        if let value = flightLoyaltyValidUntil {
            dictionary[PantryConstants.flightLoyaltyValidUntil.rawValue] = value
        }
        
        if let value = flightAnythingElse {
            dictionary["flightAnythingElse"] = value
        }
        
        if let value = carBookingClass {
            dictionary["carBookingClass"] = value
        }
        
        if let value = carType {
            dictionary["carType"] = value
        }
        
        if let value = carPreferences {
            dictionary["carPreferences"] = value
        }
        
        if let value = carExtras {
            dictionary["carExtras"] = value
        }
        
        if let value = carPreferredRentalCompanies {
            dictionary["carPreferredRentalCompanies"] = value
        }
        
        if let value = carLoyaltyPrograms {
            dictionary["carLoyaltyPrograms"] = value.toString()
        }
        
        if let value = carLoyaltyValidUntil {
            dictionary[PantryConstants.carLoyaltyValidUntil.rawValue] = value
        }
        
        if let value = carAnythingElse {
            dictionary["carAnythingElse"] = value
        }
        
        if let value = trainTravelClass {
            dictionary["trainTravelClass"] = value
        }
        
        if let value = trainCompartmentType {
            dictionary["trainCompartmentType"] = value
        }
        
        if let value = trainSeatLocation {
            dictionary["trainSeatLocation"] = value
        }
        
        if let value = trainZone {
            dictionary["trainZone"] = value
        }
        
        if let value = trainPreferred {
            dictionary["trainPreferred"] = value
        }
        
        if let value = trainSpecificBooking {
            dictionary["trainSpecificBooking"] = value
        }
        
        if let value = trainMobilityService {
            dictionary["trainMobilityService"] = value
        }
        
        if let value = trainTicket {
            dictionary["trainTicket"] = value
        }
        
        if let value = trainLoyaltyPrograms {
            dictionary["trainLoyaltyPrograms"] = value.toString()
        }
        
        if let value = trainLoyaltyValidUntil {
            dictionary[PantryConstants.trainLoyaltyValidUntil.rawValue] = value
        }
        
        if let value = trainAnythingElse {
            dictionary["trainAnythingElse"] = value
        }
        
        return dictionary
    }
    
    
    // MARK: Public
    
    func update(from formValues: Form.FormDictionary) {
        
        let json = JSON(formValues)
        
        if let array = json["personal"].array {
            title = getValue(for: "title", array: array)
            firstName = getValue(for: "first_name", array: array)
            middleName = getValue(for: "middle_name", array: array)
            lastName = getValue(for: "last_name", array: array)
            nationality = getValue(for: "nationality", array: array)
            birthDate = getValue(for: "birth_date", array: array)
        }
        
        if let array = json["contact"].array {
            addressLine1 = getValue(for: "address_line_1", array: array)
            addressLine2 = getValue(for: "address_line_2", array: array)
            city = getValue(for: "city", array: array)
            state = getValue(for: "state", array: array)
            zipCode = getValue(for: "zip", array: array)
            country = getValue(for: "country", array: array)
            keepBillingAndPrivateIdentical = getValue(for: "billing_sync", comparing: "keep_billing_sync", array: array)
        }
        
        if let array = json["contact_details"].array {
            contactEmailAddress = getValue(for: "contact_email", array: array)
            primaryEmailAddress = getValue(for: "primary_email", array: array)
            primaryPhoneNumber = getValue(for: "primary_phone", array: array)
        }
        
        if let array = json["billing_address"].array {
            companyName = getValue(for: "company_name", array: array)
            companyAddressLine1 = getValue(for: "address_line_1", array: array)
            companyAddressLine2 = getValue(for: "address_line_2", array: array)
            companyCity = getValue(for: "city", array: array)
            companyState = getValue(for: "state", array: array)
            companyZip = getValue(for: "zip", array: array)
            companyCountry = getValue(for: "country", array: array)
            companyVatId = getValue(for: "vat", array: array)
        }
        
        if let array = json["passport"].array {
            passportNumber = getValue(for: "number", array: array)
            passportCountryOfIssuance = getValue(for: "country", array: array)
            passportCityOfIssuance = getValue(for: "city", array: array)
            passportDateOfIssuance = getValue(for: "date_issued", array: array)
            passportExpiryDate = getValue(for: "expiry", array: array)
        }
        
        if let array = json["esta"].array {
            estaApplicationNumber = getValue(for: "application_number", array: array)
            estaValidUntil = getValue(for: "valid_until", array: array)
        }
        
        if let array = json["hotel"].array {
            hotelCategory = getValue(for: "category", array: array)
            hotelType = getValue(for: "hotel_type", array: array)
            hotelLocation = getValue(for: "location", array: array)
            hotelBedType = getValue(for: "bed_type", array: array)
            hotelRoomStandard = getValue(for: "room_standard", array: array)
            hotelRoomLocation = getValue(for: "room_location", array: array)
            hotelAmenities = getValue(for: "amenities", array: array)
            hotelChains = getValue(for: "preferred_hotels", array: array)
            hotelChainsBlacklist = getValue(for: "hotels_to_avoid", array: array)
            hotelLoyaltyPrograms = getValue(for: "hotel_loyalty", array: array)
            hotelLoyaltyValidUntil = getValue(for: "loyalty_date", array: array)
            hotelAnythingElse = getValue(for: "anything_else", array: array)
        }

        if let array = json["flights"].array {
            flightBookingClassShortHaul = getValue(for: "booking_class_short_haul", array: array)
            flightBookingClassMediumHaul = getValue(for: "booking_class_medium_haul", array: array)
            flightBookingClassLongHaul = getValue(for: "booking_class_long_haul", array: array)
            flightPreferredSeat = getValue(for: "preferred_seat", array: array)
            flightPreferredRow = getValue(for: "preferred_row", array: array)
            flightMealPreference = getValue(for: "meal_preferences", array: array)
            flightOptions = getValue(for: "options", array: array)
            flightAirlines = getValue(for: "preferred_airlines", array: array)
            flightAirlineBlacklist = getValue(for: "airlines_to_avoid", array: array)
            flightLoyaltyPrograms = getValue(for: "flights_loyalty", array: array)
            flightLoyaltyValidUntil = getValue(for: "loyalty_date", array: array)
            flightAnythingElse = getValue(for: "anything_else", array: array)
        }

        if let array = json["rental_car"].array {
            carBookingClass = getValue(for: "booking_class", array: array)
            carType = getValue(for: "car_type", array: array)
            carPreferences = getValue(for: "car_preferences", array: array)
            carExtras = getValue(for: "extras", array: array)
            carPreferredRentalCompanies = getValue(for: "preferred_rental_companies", array: array)
            carLoyaltyPrograms = getValue(for: "rental_car_loyalty", array: array)
            carLoyaltyValidUntil = getValue(for: "loyalty_date", array: array)
            carAnythingElse = getValue(for: "anything_else", array: array)
        }

        if let array = json["train"].array {
            trainTravelClass = getValue(for: "train_travel_class", array: array)
            trainCompartmentType = getValue(for: "train_compartment_type", array: array)
            trainSeatLocation = getValue(for: "train_seat_location", array: array)
            trainZone = getValue(for: "train_zone", array: array)
            trainPreferred = getValue(for: "train_preferred", array: array)
            trainSpecificBooking = getValue(for: "train_specific_booking", array: array)
            trainMobilityService = getValue(for: "train_mobility_service", array: array)
            trainTicket = getValue(for: "train_ticket", array: array)
            trainLoyaltyPrograms = getValue(for: "train_loyalty", array: array)
            trainLoyaltyValidUntil = getValue(for: "loyalty_date", array: array)
            trainAnythingElse = getValue(for: "anything_else", array: array)
        }
    }
    
    func postToBackendIfNeeded(andSaveLocally saveLocally: Bool = true) {
        if isDirty {
            AwsBackendManager.postUser(profile: self, { (didSucceed) in
                guard didSucceed else {
                    //TODO: Show error message
                    return
                }
                
                self.isDirty = false
                
                if saveLocally {
                    CacheManager.save(userProfile: self)
                }
            })
        }
    }
    
    func hasRequiredEmailField() -> Bool {
        guard let email = primaryEmailAddress,
            email.length > 0 else {
                return false
        }
        return EmailValidator().isValid(value: email)
    }
    
    func hasRequiredFields() -> Bool {
        return hasRequiredEmailField()
    }
    
    
    // MARK: Private
    
    private func getValue(for title: String, array: [JSON]) -> String? {
        for values in array {
            if let val = values.dictionary?[title]?.string {
                return val
            }
        }
        return nil
    }
    
    private func getValue(for title: String, array: [JSON]) -> [String]? {
        for values in array {
            if let val = values.dictionary?[title]?.arrayObject as? [String] {
                return val
            }
        }
        return nil
    }
    
    private func getValue(for title: String, array: [JSON]) -> [LoyaltyProgramEntry]? {
        for values in array {
            if let val = values.dictionary?[title]?.dictionaryObject as? [String: String] {
                return val.map({ LoyaltyProgramEntry(identifier: $0.key, value: $0.value) })
            }
        }
        return nil
    }
    
    private func getValue(for title: String, comparing value: String, array: [JSON]) -> Bool {
        for values in array {
            if let stringArray = values.dictionary?[title]?.arrayObject as? [String] {
                if stringArray.contains(value) {
                    return true
                }
            }
        }
        return false
    }
    
}


// MARK: Pantry constants

extension UserProfile {
    
    enum PantryConstants: String {
        case hotelLoyaltyValidUntil
        case flightLoyaltyValidUntil
        case trainLoyaltyValidUntil
        case carLoyaltyValidUntil
    }
}
