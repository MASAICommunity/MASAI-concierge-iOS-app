//
//  User.swift
//  masai
//
//  Created by Bartomiej Burzec on 27.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import Pantry
import SwiftyJSON
import Auth0
import SimpleKeychain


enum LoginType: String, StorableRawEnum {
    case fb, google, twitter, standard
}


struct User: Storable {
    var awsUserId: String?
    var identifier: String? // Auth0 identifier
    var token: String?
    var tokenExpired: Date?
    var email: String?
    var pass: String?
    
    var authType: LoginType?
    
    var auth0AccessToken: String?
    var auth0TokenType: String?
    var auth0expiresIn: Date?
    var auth0refreshToken: String?
    var auth0IdToken: String?
    
    init() {}
    
    init?(warehouse: Warehouseable) {
        self.awsUserId = warehouse.get("AwsUserIdentifier")
        self.identifier = warehouse.get("UserIdentifier")
        self.token = warehouse.get("UserToken")
        self.tokenExpired = Date.dateFromMasaiTimestamp(warehouse.get("UserTokenExpired"))
        self.email = warehouse.get("UserEmail")
        self.pass = warehouse.get("UserPass")
        
        if let type: String = warehouse.get("UserAuthType") {
            self.authType = LoginType(rawValue: type)
        }
        
        let keychain = A0SimpleKeychain(service: "Auth0")
        self.auth0AccessToken = keychain.string(forKey: "access_token")
        self.auth0IdToken = keychain.string(forKey: "id_token")
        self.auth0refreshToken = keychain.string(forKey: "refresh_token")
        self.auth0TokenType = keychain.string(forKey: "token_type")
    }
    
    func toDictionary() -> [String : Any] {
        var dictionary = [String : Any]()
        
        if let uid = self.awsUserId {
            dictionary["AwsUserIdentifier"] = uid
        }
        
        if let identifier =  self.identifier {
            dictionary["UserIdentifier"] = identifier
        }
        if let token = self.token {
            dictionary["UserToken"] = token
        }
        if let tokenExpired = self.tokenExpired {
            dictionary["UserTokenExpired"] = Date.masaiTimestampFromDate(tokenExpired)
        }
        if let email = self.email {
            dictionary["UserEmail"] = email
        }
        if let pass = self.pass {
            dictionary["UserPass"] = pass
        }
        
        if let authType = self.authType {
            dictionary["UserAuthType"] = authType.rawValue
        }
        
        return dictionary
    }
        
    init(_ json: JSON) {
        update(with: json)
    }
    
    mutating func update(with profile: UserProfile) {
        if let uid = profile.awsUserId {
            self.awsUserId = uid
        }
    }
    
    mutating func update(with json: JSON) {
        self.identifier = json["result"]["id"].string
        self.token = json["result"]["token"].string
        
        if let expiredDate = json["result"]["tokenExpires"]["$date"].double {
            self.tokenExpired = Date.init(timeIntervalSince1970: expiredDate / 1000)
        }
    }
    
    mutating func updateDetails(with json: JSON) {
        if let email =  json[Constants.Network.Json.emails][0][Constants.Network.Json.address].string {
            self.email = email
        }
    }
    
    mutating func update(newToken: String) {
        self.auth0IdToken = newToken
        
        let keychain = A0SimpleKeychain(service: "Auth0")
        
        if let idToken = self.auth0IdToken {
            keychain.setString(idToken, forKey: "id_token")
        }
        
    }
    
    mutating func update(with credentials: Credentials) {
        self.auth0AccessToken = credentials.accessToken
        self.auth0expiresIn = credentials.expiresIn
        self.auth0TokenType = credentials.tokenType
        self.auth0refreshToken = credentials.refreshToken
        self.auth0IdToken = credentials.idToken
        
        let keychain = A0SimpleKeychain(service: "Auth0")
        
        if let accessToken = self.auth0AccessToken {
            keychain.setString(accessToken, forKey: "access_token")
        }
        
        if let idToken = self.auth0IdToken {
            keychain.setString(idToken, forKey: "id_token")
        }
        
        if let tokenType = self.auth0TokenType {
            keychain.setString(tokenType, forKey: "token_type")
        }
        
        if let refreshToken = self.auth0refreshToken {
            keychain.setString(refreshToken, forKey: "refresh_token")
        }
    }
    
    mutating func update(with profile: Profile) {
        if let email = profile.email {
            self.email = email
        }
        self.identifier = profile.id
    }
    
    func clearCredentials() {
        A0SimpleKeychain(service: "Auth0").clearAll()
    }
}
