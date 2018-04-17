//
//  RocketChatPushNotifications.swift
//  masai
//
//  Created by Florian Rath on 16.11.17.
//  Copyright © 2017 5lvlup gmbh. All rights reserved.
//

import Foundation


class RocketChatPushNotifications {
    
    // MARK: Types
    
    typealias RegisterCompletion = (_ didSucceed: Bool) -> Void
    
    
    // MARK: Properties
    
    static let appName = "db-concierge"
    static let keychainKey = "RocketChatPushNotifications.dbEntryId"
    
    
    // MARK: Public
    
    static func register(deviceToken: String, userId: String, socketManager: SocketManager, completion: RegisterCompletion?) {
        
        var requestParameters = [
            Constants.Network.Json.id: "",
            Constants.Network.Json.token: [
                Constants.Network.Json.apn: deviceToken
            ],
            Constants.Network.Json.appName: RocketChatPushNotifications.appName,
            Constants.Network.Json.userId: userId,
            Constants.Network.Json.metadata: [:]
            ] as [String : Any]
        
        if let recordId = RocketChatPushNotifications.getRecordId(for: socketManager.host.name) {
            requestParameters[Constants.Network.Json.id] = recordId
        }
        
        let requestObject: [String: Any] = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.registerPushToken,
            Constants.Network.Json.params: [requestParameters]
        ]
        
        socketManager.send(requestObject) { (response: SocketResponseMessage) in
            print("push register response: \(response)")
            /*
             {
             "id" : "DqRlVi6wm5kp7oXW082Gspfk3pWKtISKWVhnylFoFZmOCFXlt2",
             "result" : {
                "_id" : "C78C8AE6-E1C4-471B-AD72-C8E5D431CB80",
                "userId" : "hEqBwuoRzmyQjt25h",
                "enabled" : true,
                "appName" : "db-concierge",
                "updatedAt" : {
                    "$date" : 1510840025589
                },
                "token" : {
                    "apn" : "e299ec7c62415fb3ae0f9d29810245f1215cb37d7d75dd6d6ce65eb56054b6df"
                },
                "createdAt" : {
                    "$date" : 1510840005274
                }
             },
             "msg" : "result"
             }
             */
            
            if let recordId = response.responseData[Constants.Network.Json.result][Constants.Network.Json.identifier].string {
                RocketChatPushNotifications.set(recordId: recordId, for: socketManager.host.name)
            }
            
            completion?(true)
        }
    }
    
    
    // MARK: Private
    
    private static func getRecordId(for hostName: String) -> String? {
        return RocketChatPushNotifications.getRecords()[hostName]
    }
    
    private static func set(recordId: String, for hostName: String) {
        var records = RocketChatPushNotifications.getRecords()
        records[hostName] = recordId
        
        let data = NSKeyedArchiver.archivedData(withRootObject: records)
        UserDefaults.standard.set(data, forKey: RocketChatPushNotifications.keychainKey)
        UserDefaults.standard.synchronize()
    }
    
    private static func getRecords() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: RocketChatPushNotifications.keychainKey),
            let recordIds = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String] else {
                return [:]
        }
        return recordIds
    }
    
}
