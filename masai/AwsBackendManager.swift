//
//  AwsBackendManager.swift
//  masai
//
//  Created by Florian Rath on 23.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct AwsBackendManager {
    
    // MARK: Notifications
    
    static let didUpdateUserProfileNotification = NSNotification.Name("AwsBackendManager.didUpdateUserProfile")
    
    
    // MARK: Types
    
    typealias UserProfileResponseCompletion = (_ didSucceed: Bool) -> Void
    typealias ChoicesResponseCompletion = (_ didSucceed: Bool, _ choices: ProfileChoices?) -> Void
    typealias TransactionIdCompletion = (_ didSucceed: Bool) -> Void
    typealias AccessGrantsCompletion = (_ didSucceed: Bool, _ grants: [AccessGrant]? ) -> Void
    typealias DeleteAccessGrantCompletion = (_ didSucceed: Bool) -> Void
    typealias JourneyResponseCompletion = (_ didSucceed: Bool, _ journeys: [Journey]?) -> Void
    typealias GetHostsCompletion = (_ hosts: [Host]?) -> Void
    
    
    // MARK: Public
    
    static func getUserProfile(_ completion: UserProfileResponseCompletion? = nil) {
        guard let authHeaders = authorizationHeaders,
            var cachedUser = CacheManager.retrieveLoggedUser() else {
            completion?(false)
            return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.userProfile
        
        Alamofire.request(requestAddress, parameters: nil, encoding: URLEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false)
                    return
                    
                case .validationException:
                    completion?(false)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false)
                    return
                }
            }
            
            let profile = ProfileTransformator.transform(json: jsonResponse)
            cachedUser.update(with: profile)
            CacheManager.saveLoggedUser(cachedUser)
            CacheManager.save(userProfile: profile)
            
            NotificationCenter.default.post(name: didUpdateUserProfileNotification, object: nil)
            
            completion?(true)
        }
    }
    
    static func postUser(profile: UserProfile, _ completion: UserProfileResponseCompletion? = nil) {
        guard let authHeaders = authorizationHeaders,
            let cachedUser = CacheManager.retrieveLoggedUser() else {
                completion?(false)
                return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.userProfile
        
        let body = ProfileTransformator.transform(user: cachedUser, profile: profile)
        
        var headers = authHeaders
        headers["Content-type"] = "application/json; charset=utf-8"// "application/x-www-form-urlencoded; charset=utf-8" //"application/json; charset=utf-8"
        headers["Accept"] = "application/json, text/plain, */*"
        
        Alamofire.request(requestAddress, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false)
                    return
                    
                case .validationException:
                    completion?(false)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false)
                    return
                }
            }
            
            completion?(true)
        }
    }
    
    static func getChoices(_ completion: @escaping ChoicesResponseCompletion) {
        guard let authHeaders = authorizationHeaders else {
                completion(false, nil)
                return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.choices
        
        Alamofire.request(requestAddress, parameters: nil, encoding: URLEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion(false, nil)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion(false, nil)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion(false, nil)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            let items = jsonResponse["Items"].arrayValue
            let choices = ProfileChoices.from(json: items)
            
            completion(true, choices)
        }
    }
    
    static func postNewTransactionId(_ completion: TransactionIdCompletion? = nil) {
        guard let authHeaders = authorizationHeaders else {
            completion?(false)
            return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.transactions
        
        Alamofire.request(requestAddress, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false)
                    return
                    
                case .validationException:
                    completion?(false)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false)
                    return
                }
            }
            
            completion?(true)
        }
    }
    
    static func getAccessGrants(_ completion: AccessGrantsCompletion? = nil) {
        guard let authHeaders = authorizationHeaders else {
                completion?(false, nil)
                return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.accessGrants
        
        Alamofire.request(requestAddress, parameters: nil, encoding: URLEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false, nil)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false, nil)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false, nil)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false, nil)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false, nil)
                    return
                    
                case .validationException:
                    completion?(false, nil)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false, nil)
                    return
                }
            }
            
            let grants = AccessGrant.from(json: jsonResponse)
            
            completion?(true, grants)
        }
    }
    
    static func deleteAccessGrants(_ grants: [AccessGrant], completion: AccessGrantsCompletion? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            
            var didAllSucceed = true
            
            for grant in grants {
                queue.addOperation {
                    let semaphore = DispatchSemaphore(value: 0)
                    self.deleteAccessGrant(grant, completion: { (didSucceed) in
                        if !didSucceed {
                            didAllSucceed = false
                        }
                        semaphore.signal()
                    })
                    let result = semaphore.wait(timeout: .now() + 30)
                    if result == .timedOut {
                        didAllSucceed = false
                    }
                }
            }
            
            queue.waitUntilAllOperationsAreFinished()
            
            self.getAccessGrants({ (didSucceed, grants) in
                completion?(didAllSucceed, grants)
            })
        }
    }
    
    static func deleteAccessGrant(_ grant: AccessGrant, completion: DeleteAccessGrantCompletion? = nil) {
        guard let authHeaders = authorizationHeaders else {
            completion?(false)
            return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.deleteAccessGrant(for: grant.grantedToUserId)
        
        Alamofire.request(requestAddress, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false)
                    return
                    
                case .validationException:
                    completion?(false)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false)
                    return
                }
            }
            
            completion?(true)
        }
    }
    
    static func getJourneys(searchTerm: String?, scope: Int, _ completion: JourneyResponseCompletion? = nil) {
        
//        // Mock response
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { 
//            let journeyMockString = JourneyMockJson.jsonString()
//            guard let data = journeyMockString.data(using: String.Encoding.utf8) else {
//                completion?(false, nil)
//                return
//            }
//            let journeys = JSON(data)
//            guard let journeyArray = journeys.array else {
//                completion?(false, nil)
//                return
//            }
//
//            var parsedJourneys: [Journey] = []
//            for journeyJson in journeyArray {
//                let journey = Journey(json: journeyJson)
//                parsedJourneys.append(journey)
//            }
//
//            completion?(true, parsedJourneys)
//        }
        
        // Actual backend query
        guard let authHeaders = authorizationHeaders else {
                completion?(false, nil)
                return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.journeys
        var params: Parameters = [:]
        if let search = searchTerm {
            params["filter-text"] = search
        }
        params["filter-time"] = scope
        
        Alamofire.request(requestAddress, parameters: params, encoding: URLEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion?(false, nil)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion?(false, nil)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion?(false, nil)
                return
            }
            
            let journeys = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: journeys, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion?(false, nil)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion?(false, nil)
                    return
                    
                case .validationException:
                    completion?(false, nil)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion?(false, nil)
                    return
                }
            }
            
            guard let journeyArray = journeys.array else {
                completion?(false, nil)
                return
            }
            
            var parsedJourneys: [Journey] = []
            for journeyJson in journeyArray {
                let journey = Journey(json: journeyJson)
                parsedJourneys.append(journey)
            }
            
            completion?(true, parsedJourneys)
        }
    }
    
    static func getHostList(_ completion: @escaping GetHostsCompletion) {
//        // For now the response is only mocked
//        let liveUrl = "http://chat.journey-concierge.com:3001/"
//        let liveSocketUrl = "http://chat.journey-concierge.com:3001/websocket"
//        let liveName = "DB Concierge"
//        let liveLiveChatToken = "randomAndMockedStringWhichShouldBeUniquePerUser"
//        let live = Host(url: liveUrl, socketUrl: liveSocketUrl, name: liveName, liveChatToken: liveLiveChatToken, credentials: nil)
//
//        let devUrl = "http://54.229.202.146:3001/"
//        let devSocketUrl = "http://54.229.202.146:3001/websocket"
//        let devName = "5lvlup Test"
//        let devLiveChatToken = "randomAndMockedStringWhichShouldBeUniquePerUser"
//        let dev = Host(url: devUrl, socketUrl: devSocketUrl, name: devName, liveChatToken: devLiveChatToken, credentials: nil)
//
//        let mockedHosts = [live, dev]
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            completion(mockedHosts)
//        }
//        return
        
        // Actual backend response
        guard let authHeaders = authorizationHeaders else {
                completion(nil)
                return
        }
        
        let requestAddress = Constants.Network.AwsBackend.Endpoints.hosts
        
        Alamofire.request(requestAddress, parameters: nil, encoding: URLEncoding.default, headers: authHeaders).responseString(encoding: String.Encoding.utf8) { (response) in
            if let statusCode = response.response?.statusCode {
                
                guard !handledDefault(statusCode: statusCode) else {
                    completion(nil)
                    return
                }
                
                guard statusCode == 200 else {
                    assert(false, "http status code was: \(response.response?.statusCode ?? 0)\nresponse was: \(response.value ?? "nil")")
                    completion(nil)
                    return
                }
            }
            
            guard let jsonString = response.value else {
                completion(nil)
                return
            }
            
            let jsonResponse = JSON.init(parseJSON: jsonString)
            
            if let error = AwsBackendError.fromJson(json: jsonResponse, httpStatusCode: response.response?.statusCode) {
                switch error {
                case .unauthorized:
                    completion(nil)
                    AppDelegate.logout()
                    return
                    
                case .unsupportedMediaType:
                    completion(nil)
                    return
                    
                case .validationException:
                    completion(nil)
                    return
                    
                case .unknownError:
                    assert(false, "Request most likely failed with an unhandled message - is that true?")
                    completion(nil)
                    return
                }
            }
            
            var transformedHosts: [Host] = []
            for hostJson in jsonResponse.arrayValue {
                let name = hostJson["name"].stringValue
                let url = hostJson["url"].stringValue
                let socketUrl = hostJson["socket"].stringValue
                let liveChatToken = hostJson["liveChatToken"].stringValue
                let host = Host(url: url, socketUrl: socketUrl, name: name, liveChatToken: liveChatToken, credentials: nil)
                transformedHosts.append(host)
            }
            
            completion(transformedHosts)
        }
    }
    
    
    // MARK: Private
    
    static var authorizationHeaders: [String: String]? {
        guard let cachedUser = CacheManager.retrieveLoggedUser(),
            let token = cachedUser.auth0IdToken else {
            return nil
        }
        return [Constants.Network.AwsBackend.Authorization.authorizationHeader: "Bearer \(token)"]
    }
    
    private static func handledDefault(statusCode: Int) -> Bool {
        if statusCode == 500 {
            AppDelegate.logout(withMessage: "service_not_available".localized)
            return true
        }
        
        return false
    }
    
}
