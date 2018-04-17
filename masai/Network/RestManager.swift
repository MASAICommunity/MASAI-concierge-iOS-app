//
//  RestManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import SwiftyJSON
import Alamofire
import RealmSwift
import Foundation

typealias UserDetailsResponseCompletion = (Bool) -> Void
typealias LotusMessegeResponseCompletion = (Bool) -> Void
typealias LocationDetailsResponseCompletion = (JSON?, Bool) -> Void
typealias TravelfolderAccessRequestResposneCompletion = (Bool) -> Void
typealias ResetAuth0UserPass = (Bool) -> Void

struct RestManager {
    
    
    static func resetAuth0UserPass(_ email: String, completion: @escaping ResetAuth0UserPass) {
        
        let parameters = [
            Constants.Network.Json.clientId: Constants.Auth0.clientId,
            Constants.Network.Json.email: email,
            Constants.Network.Json.connection: Constants.Auth0.resetPassConnection
        ]
        
        Alamofire.request(Constants.Auth0.resetPassEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            print(response)
            completion(response.result.isSuccess)
        }
    
    }
    
    
    static func giveTravelFolderPermission(_ addres: String, body: String, completion: @escaping TravelfolderAccessRequestResposneCompletion) {
        
        if let user = CacheManager.retrieveLoggedUser(), let authToken = user.auth0IdToken, let parameters: Parameters = JSON.init(parseJSON: body).dictionaryObject {
            
            let auth = "Bearer \(authToken)"
            let headers: HTTPHeaders = [
                "Authorization" : auth
            ]

            Alamofire.request(addres, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
                completion(response.result.isSuccess)
            }
        } else {
            completion(false)
        }
    }
    
    static func getLocationDetails(lat: Double, long: Double, completion: LocationDetailsResponseCompletion? = nil) {
        let endpoint = Constants.Google.locationDetailsEndpoint + "\(lat),\(long)"
        
        Alamofire.request(endpoint).responseString { (response) in
            guard let jsonString = response.value else {
                completion?(nil, false)
                return
            }
            
            let json = JSON.init(parseJSON: jsonString)
            completion?(json, true)
        }
    }
    
}
