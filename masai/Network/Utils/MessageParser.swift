//
//  MessageParser.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import Realm


struct MessageParser {
    
    static func parse(_ json: JSON) -> ChatMessage? {
        
        var newMessage: ChatMessage?
        
        let chatMessageContent = JSON(parseJSON: json[Constants.Network.Json.message].stringValue)
        if chatMessageContent.isEmpty == false {
            
            if chatMessageContent[Constants.Network.Json.url].exists() && chatMessageContent[Constants.Network.Json.payload].exists() {
                newMessage = ChatMessage.getOrCreate(identifier: json[Constants.Network.Json.identifier].string, jsonData: json, updates: { (msg) in
                    msg?.sent = true
                    msg?.permissionLink = chatMessageContent[Constants.Network.Json.url].string
                    msg?.permissionPayload = chatMessageContent[Constants.Network.Json.payload].rawString()
                    msg?.isPermission = true
                    msg?.linkAttached = false
                })
                
            } else if chatMessageContent[Constants.Network.Json.status].exists() && chatMessageContent[Constants.Network.Json.granted].exists() {
                newMessage = ChatMessage.getOrCreate(identifier: json[Constants.Network.Json.identifier].string, jsonData: json, updates: { (msg) in
                    msg?.sent = true
                    msg?.isPermissionAnswer = true
                    
                    if chatMessageContent[Constants.Network.Json.status].string == Constants.Network.PermissionsTypes.granted {
                        msg?.permissionAnswerGranted = true
                    } else {
                        msg?.permissionAnswerGranted = false
                    }
                })

            } else {
                newMessage = ChatMessage.getOrCreate(identifier: json[Constants.Network.Json.identifier].string, jsonData: json, updates: { (msg) in
                    msg?.googlePlacesAttached = true
                    msg?.sent = true
                    for placeJSON in chatMessageContent[Constants.Network.Json.results].arrayValue {
                        let place = GooglePlace.getOrCreate(identifier:placeJSON[Constants.Network.Json.id].string, jsonData: placeJSON, updates: nil)
                        if msg?.googlePlaces.contains(place) == false {
                            msg?.googlePlaces.append(place)
                        }
                    }
                })
            }
            
        } else if let imageName = json[Constants.Network.Json.attachments][0][Constants.Network.Json.imageURL].string?.components(separatedBy: "/").last, let messageWithImage = ChatMessage.messageForImageUpdate(json[Constants.Network.Json.rid].stringValue, imageName: imageName){
            
            Realm.execute({ _ in
                messageWithImage.update(with: json)
                messageWithImage.sent = true
                messageWithImage.imageStoredLocally = false
            })
            
            CacheManager.removeCachedImage(imageName)
            
            newMessage = messageWithImage
            
        } else {
            newMessage = ChatMessage.getOrCreate(identifier: json[Constants.Network.Json.identifier].string, jsonData: json, updates: { (msg) in
                msg?.sent = true
            })
            
        }
        
        if let message = newMessage {
            Realm.execute({ (realm) in
                realm.add(message, update: true)
            })
        }
        
        return newMessage
    }
    
}
