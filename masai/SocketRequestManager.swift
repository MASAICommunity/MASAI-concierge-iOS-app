//
//  SockeRequestManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import PromiseKit


enum HistoryError: Error {
    case noRoomNumberSet
    case errorOccurred
    case invalidRoom(roomId: String)
}

extension SocketManager {
    
    // MARK: Types
    
    typealias SubscriptionResponseCompletion = (SocketResponseMessage, [Channel]?) -> Void
    typealias CreateChannelResponseCompletion = (SocketResponseMessage, Channel?) -> Void
    typealias SendTextMessageResponseCompletion = (_ generatedChatMessage: ChatMessage?, _ updatedChannel: Channel, _ updatdHost: Host?) -> Void
    typealias ResetPassResponsecCompletion = (SocketResponseMessage, Bool?) -> Void
    typealias RegisterToLiveChatCompletion = (SocketResponseMessage?, Channel?, LiveChatCredentials?) -> Void
    typealias GetInitialDataCompletion = (SocketResponseMessage?) -> Void
    typealias SendLocalizationResponseCompletion = (_ response: SocketResponseMessage?, _ message: ChatMessage?) -> Void
    typealias SendLiveChatMessageCompletion = (SocketResponseMessage) -> Void
    typealias GetChannelsClosure = (_ channels: [Channel]) -> Void
    
    
    // MARK: Public
    
    func resendLocalization(roomId rid: String, message: ChatMessage) {
        guard let msgIdentifier = message.identifier else {
                return
        }
        
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.sendMessage,
            Constants.Network.Json.params: [[
                Constants.Network.Json.location: [
                    Constants.Network.Json.coordinates: [message.longitude, message.latitude],
                    Constants.Network.Json.type: Constants.Network.Json.point
                ],
                Constants.Network.Json.identifier: msgIdentifier,
                Constants.Network.Json.rid: rid,
                Constants.Network.Json.timestamp: [
                    Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
                Constants.Network.Json.message: ""
                ]]
            ] as [String : Any]
        
        
        send(requestObject)
    }
    
    func sendLocalization(roomId rid: String, lat: Double, long: Double, name: String?, completion: SendLocalizationResponseCompletion?) {
        let messageIdentifier = String.random(length: 18)
        
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.sendMessage,
            Constants.Network.Json.params: [[
                Constants.Network.Json.location: [
                    Constants.Network.Json.coordinates: [long, lat],
                    Constants.Network.Json.type: Constants.Network.Json.point
                ],
                Constants.Network.Json.identifier: messageIdentifier,
                Constants.Network.Json.rid: rid,
                Constants.Network.Json.timestamp: [
                    Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
                Constants.Network.Json.message: ""
                ]]
            ] as [String : Any]
        
        var messageOwner = ""
        if let username = host.credentials?.liveChatUsername {
            messageOwner = username
        }
        
        let messageObject = [
            Constants.Network.Json.identifier: messageIdentifier,
            Constants.Network.Json.rid: rid,
            Constants.Network.Json.message: "",
            Constants.Network.Json.timestamp: [
                Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
            Constants.Network.Json.location: [
                Constants.Network.Json.coordinates: [long, lat],
                Constants.Network.Json.type: Constants.Network.Json.point
            ],
            Constants.Network.Json.userInfo:[
                Constants.Network.Json.username: messageOwner
            ]] as [String: Any]
        
        let messageJson = JSON(messageObject)
        let newMessage = ChatMessage.getOrCreate(identifier: messageJson[Constants.Network.Json.identifier].string, jsonData: messageJson, updates: nil)
        
        HostConnectionManager.shared.activeHost(forRoomId: rid) { [unowned self] (host: Host?) in
            Realm.execute({ (realm) in
                newMessage.locationName = name
                if let host = host {
                    newMessage.sending = self.isConnected(with: host)
                }
                newMessage.locationAttached = true
                realm.add(newMessage, update: true)
            })
            
            self.send(requestObject) { (response) in
                print("send localization response:\n\(response)")
                completion?(response, newMessage)
            }
        }
    }
    
    func resendTextMessage(in channel: Channel, message: ChatMessage) {
        assert(channel.roomId != nil, "Room id must not be nil, since we cannot resend the message")
        if channel.roomId == nil {
//            // Channel is not yet registered on rocket chat, so we'll send a livechat message instead
//            sendLiveChatMessage(message: message.messageText!, userLiveChatId: (host.credentials?.liveChatUserId)!, userLoginToken: (host.credentials?.liveChatUserLoginToken)!, liveChatToken: host.liveChatToken, username: (host.credentials?.liveChatUsername)!, completion: { (_, _, _) in
//            })
            return
        }
        
        guard let rid = channel.roomId,
            let msgIdentifier = message.identifier,
            let msg = message.messageText else {
                return
        }
        
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.sendMessage,
            Constants.Network.Json.params: [[
                Constants.Network.Json.identifier: msgIdentifier,
                Constants.Network.Json.rid: rid,
                Constants.Network.Json.message: msg,
                Constants.Network.Json.timestamp: [
                    Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
                
                ]]
            ] as [String : Any]
        
        send(requestObject)
    }
    
    
    func sendTextMessage(in channel: Channel, message messageString: String, completion: SendTextMessageResponseCompletion?) {
        let messageIdentifier = String.random(length: 18)
        
        HostConnectionManager.shared.host(for: channel) { [unowned self] (host: Host?) in
            guard let host = host else {
                completion?(nil, channel, nil)
                return
            }
            
            let credentials = host.credentials ?? LiveChatCredentials()
            
            // If the channel does not have a room yet, we'll create one
            let rid = channel.roomId
            if rid == nil {
                let liveChatToken = host.liveChatToken
                
                if credentials.liveChatUserId == nil ||
                    credentials.liveChatUserLoginToken == nil ||
                    credentials.liveChatUsername == nil {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                        self.registerToLiveChat { [unowned self] (response: SocketResponseMessage?, c: Channel?, credentials: LiveChatCredentials?) in
                            
                            print("send text message 1 response:\n\(String(describing: response))")
                            
                            let tuple = HostConnectionManager.shared.update(credentials: credentials, for: host)
                            self.host = tuple.updatedHost
                                
                            self.sendTextMessage(in: channel, message: messageString, completion: completion)
                        }
                    })
                    return
                }
                
                let liveChatUserId = credentials.liveChatUserId!
                let userLoginToken = credentials.liveChatUserLoginToken!
                let username = credentials.liveChatUsername!
                
                self.sendLiveChatMessage(message: messageString, userLiveChatId: liveChatUserId, userLoginToken: userLoginToken, liveChatToken: liveChatToken, username: username, completion: { (response: SocketResponseMessage) in
                    
                    /*
                     {
                     "_id" : "laK2jJ1u4HmZFAjnq",
                     "alias" : "florian",
                     "_updatedAt" : {
                     "$date" : 1509636636544
                     },
                     "ts" : {
                     "$date" : 1509636636541
                     },
                     "rid" : "ViIrmplLTXVrY95x2",
                     "u" : {
                     "_id" : "hEqBwuoRzmyQjt25h",
                     "username" : "guest-1271"
                     },
                     "msg" : "Eine Testanfrage",
                     "newRoom" : true,
                     "token" : "randomAndMockedStringWhichShouldBeUniquePerUser",
                     "showConnecting" : true
                     }
                     */
                    print("send text message 2 response:\n\(response)")
                    
                    guard response.error == nil else {
                        completion?(nil, channel, self.host)
                        return
                    }
                    
                    // Retrieve the room id from the response
                    let rid = response.responseData[Constants.Network.Json.result][Constants.Network.Json.rid].stringValue
                    var updatedChannel = channel
                    updatedChannel.roomId = rid
                    
                    // Update system username
                    var creds = self.host.credentials ?? LiveChatCredentials()
                    creds.liveChatUsername = response.responseData[Constants.Network.Json.result][Constants.Network.Json.userInfo][Constants.Network.Json.username].string
                    
                    let tuple = HostConnectionManager.shared.update(credentials: creds, for: self.host)
                    self.host = tuple.updatedHost
                    
                    let now = Date()
                    let message = ChatMessage()
                    message.identifier = messageIdentifier
                    message.rid = rid
                    message.messageText = messageString
                    message.date = now
                    message.updated = now
                    message.username = creds.liveChatUsername
                    message.sent = true
                    completion?(message, updatedChannel, self.host)
                })
                return
            }
            
            // Conversation does have a room, so we'll just send the message
            let requestObject = [
                Constants.Network.Json.message: Constants.Network.Json.method,
                Constants.Network.Json.method: Constants.Network.Methods.sendMessage,
                Constants.Network.Json.params: [[
                    Constants.Network.Json.identifier: messageIdentifier,
                    Constants.Network.Json.rid: rid!,
                    Constants.Network.Json.message: messageString,
                    Constants.Network.Json.timestamp: [
                        Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
                    
                    ]]
                ] as [String : Any]
            
            var messageOwner = ""
            if let username = credentials.liveChatUsername {
                messageOwner = username
            }
            
            let messageObject = [
                Constants.Network.Json.identifier: messageIdentifier,
                Constants.Network.Json.rid: rid!,
                Constants.Network.Json.message: messageString,
                Constants.Network.Json.timestamp: [
                    Constants.Network.Json.date: Date.masaiTimestampFromDate(Date())],
                Constants.Network.Json.userInfo:[
                    Constants.Network.Json.username: messageOwner
                ]] as [String: Any]
            
            let messageJson = JSON(messageObject)
            let newMessage = ChatMessage.getOrCreate(identifier: messageJson[Constants.Network.Json.identifier].string, jsonData: messageJson, updates: nil)
            
            Realm.execute({ (realm) in
                newMessage.sending = self.isConnected(with: host)
                realm.add(newMessage, update: true)
            })
            
            self.send(requestObject) { (response) in
                print("send text message 3 response:\n\(response)")
                
                completion?(newMessage, channel, self.host)
            }
        }
    }
    
    
    func registerToLiveChat(_ completion: @escaping RegisterToLiveChatCompletion) {
        guard let user = CacheManager.retrieveLoggedUser(),
            let email = user.email else {
            completion(nil, nil, nil)
            return
        }
        
        var username = email
        if let profile = CacheManager.retrieveUserProfile(),
            let firstName = profile.firstName,
            let lastName = profile.lastName {
            username = "\(firstName) \(lastName)"
        }

        getInitialData(liveChatToken: host.liveChatToken) { (response: SocketResponseMessage?) in
            /*
             {
             "transcript" : false,
             "registrationForm" : false,
             "offlineTitle" : "Leave a message",
             "triggers" : [
             
             ],
             "displayOfflineForm" : true,
             "offlineSuccessMessage" : "",
             "departments" : [
             
             ],
             "offlineMessage" : "We are not online right now. Please leave us a message:",
             "title" : "Masai Chat",
             "color" : "#C1272D",
             "room" : null,
             "offlineUnavailableMessage" : "",
             "enabled" : true,
             "offlineColor" : "#666666",
             "videoCall" : false,
             "language" : "",
             "transcriptMessage" : "Would you like a copy of this chat emailed?",
             "online" : true,
             "allowSwitchingDepartments" : true
             }
             */
            print("register live chat response:\n\(String(describing: response))")
            
            // Since we skipped initial data, we'll also skip error guards
//            guard response.errorOccured() == false else {
//                completion(response, nil, nil)
//                return
//            }
            
            self.registerOrLoginLiveChatUser(username: username, email: email, liveChatToken: self.host.liveChatToken, completion: completion)
        }
    }
    
    private func getInitialData(liveChatToken: String, _ completion: @escaping GetInitialDataCompletion) {
        // Since we don't do anything with initial data yet, we'll just skip the call
        completion(nil)
        return
        
//        let requestObject: [String: Any] = [
//            Constants.Network.Json.message: Constants.Network.Json.method,
//            Constants.Network.Json.method: Constants.Network.Methods.getInitialData,
//            Constants.Network.Json.params: [liveChatToken]
//        ]
//
//        send(requestObject) { (response) in
//            // Sample Response:
//            /*
//             {
//             "id" : "yZa78O1AOq69p9eq3TO11itusmbA5tUhUJuTwFUyDxiLoqHmqW",
//             "result" : {
//             "transcript" : false,
//             "registrationForm" : false,
//             "offlineTitle" : "Leave a message",
//             "triggers" : [
//
//             ],
//             "displayOfflineForm" : true,
//             "offlineSuccessMessage" : "",
//             "departments" : [
//
//             ],
//             "offlineMessage" : "We are not online right now. Please leave us a message:",
//             "title" : "Masai Chat",
//             "color" : "#C1272D",
//             "room" : null,
//             "offlineUnavailableMessage" : "",
//             "enabled" : true,
//             "offlineColor" : "#666666",
//             "videoCall" : false,
//             "language" : "",
//             "transcriptMessage" : "Would you like a copy of this chat emailed?",
//             "online" : true,
//             "allowSwitchingDepartments" : true
//             }
//             */
//
//            print("initial data response:\n\(response)")
//
//            completion(response)
//        }
    }
    
    private func registerOrLoginLiveChatUser(username: String, email: String, liveChatToken: String, completion: @escaping RegisterToLiveChatCompletion) {
        
        if let credentials = host.credentials,
            let userLoginToken = credentials.liveChatUserLoginToken,
            let _ = credentials.liveChatUserId {
            
            // We are already registered on the live chat, so we just login
            self.loginToLiveChat(userLoginToken: userLoginToken)
                .then { (response: SocketResponseMessage) -> Void in
                    print("register live chat 2 response:\n\(response)")
                    
                    guard response.errorOccured() == false else {
                        completion(response, nil, nil)
                        return
                    }
                    
                    // Create a new channel
                    let newChannel = Channel(name: self.host.name)
                    
                    completion(response, newChannel, credentials)
                }
                .catch { (error: Error) in
            }
            return
        }
        
        // We are not yet registered on the live chat, so we'll register
        
        let requestObject: [String: Any] = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.registerGuest,
            Constants.Network.Json.params: [[
                Constants.Network.Json.token: liveChatToken,
                Constants.Network.Json.name: username,
                Constants.Network.Json.email: email
                ]]
        ]
        
        send(requestObject, completionResponse: { [unowned self] (response) in
            // Sample response:
            /*
             {
             "id" : "gNwRkKyl4QOS5BK04XMrgBxyzi6OMSI03RTBUk4hAlN3Csfq1U",
             "result" : {
             "token" : "jWjnieWzzkdgL4xJawrPmA_YDPZ4trKKEuev0Ey0WEu",
             "userId" : "hEqBwuoRzmyQjt25h"
             }
             */
            
            print("register live chat user response:\n\(response)")
            
            guard response.errorOccured() == false else {
                completion(response, nil, nil)
                return
            }
            
            guard let userLoginToken = response.responseData[Constants.Network.Json.result][Constants.Network.Json.token].string else {
                completion(response, nil, nil)
                return
            }
            
            // Create new live chat credentials
            var credentials = self.host.credentials ?? LiveChatCredentials()
            credentials.liveChatUserLoginToken = userLoginToken
            credentials.liveChatUserId = response.responseData[Constants.Network.Json.result][Constants.Network.Json.userId].string
            credentials.liveChatUsername = CacheManager.retrieveLoggedUser()?.email ?? ""
            
            let tuple = HostConnectionManager.shared.update(credentials: credentials, for: self.host)
            self.host = tuple.updatedHost
            
            // Since we now registered, we'll send our push token to the server (if we have one)
            if let deviceToken = AppDelegate.get().pushNotificationHandler.deviceToken {
                RocketChatPushNotifications.register(deviceToken: deviceToken, userId: credentials.liveChatUserId!, socketManager: self, completion: { [unowned self] (didSucceed: Bool) in
                    // We registered for pushes, so we can login now
                    self.registerOrLoginLiveChatUser(username: username, email: email, liveChatToken: liveChatToken, completion: completion)
                })
            } else {
                // No push token available yet, so we'll just login
                self.registerOrLoginLiveChatUser(username: username, email: email, liveChatToken: liveChatToken, completion: completion)
            }
        })
    }
    
    
    /// Logs into a live chat (but does not send a message).
    ///
    /// - Parameter userLoginToken: The resume token
    /// - Returns: A promise getting fulfilled with the response (currently promise never gets rejected).
    func loginToLiveChat(userLoginToken token: String) -> Promise<SocketResponseMessage> {
        let requestObject: [String: Any] = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.login,
            Constants.Network.Json.params: [[
                Constants.Network.Json.resume: token
                ]]
        ]
        
        return Promise { fulfill, reject in
            send(requestObject, completionResponse: { (response) in
                /*
                 the token returned is actually the same as the token passed (userLoginToken)
                 {
                 "id" : "hEqBwuoRzmyQjt25h",
                 "token" : "RDn1tIYUpVfvRiCpc0z7lbQ7kSNw3u4hPOE3JablgjZ",
                 "tokenExpires" : {
                 "$date" : 1517412589432
                 }
                 */
                print("original token: \(token)")
                print("login to live chat response:\n\(response)")
                
                fulfill(response)
            })
        }
    }
    
    
    /// Sends a live chat message (which implicitly registers a new live chat room).
    ///
    /// - Parameters:
    ///   - message: The message to begin the new live chat with
    ///   - userLiveChatId: <#userLiveChatId description#>
    ///   - userLoginToken: <#userLoginToken description#>
    ///   - liveChatToken: <#token description#>
    ///   - username: <#username description#>
    ///   - completion: <#completion description#>
    func sendLiveChatMessage(message: String, userLiveChatId: String, userLoginToken: String, liveChatToken: String, username: String, completion: @escaping SendLiveChatMessageCompletion) {
        let randomRid = String.random(length: 17)
        
        let requestObject: [String: Any] = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.sendLiveChatMessage,
            Constants.Network.Json.params: [[
                Constants.Network.Json.identifier: String.random(length: 17),
                Constants.Network.Json.token: liveChatToken,
                Constants.Network.Json.message: message, //"live_chat_welcome_message".localized,
                Constants.Network.Json.rid: randomRid
                ]]
        ]
        
        send(requestObject, completionResponse: { (response) in
            /*
             {
             "_id" : "laK2jJ1u4HmZFAjnq",
             "alias" : "florian",
             "_updatedAt" : {
             "$date" : 1509636636544
             },
             "ts" : {
             "$date" : 1509636636541
             },
             "rid" : "ViIrmplLTXVrY95x2",
             "u" : {
             "_id" : "hEqBwuoRzmyQjt25h",
             "username" : "guest-1271"
             },
             "msg" : "Eine Testanfrage",
             "newRoom" : true,
             "token" : "randomAndMockedStringWhichShouldBeUniquePerUser",
             "showConnecting" : true
             }
             */
            print("send live chat message response:\n\(response)")
            
            guard response.errorOccured() == false else {
                completion(response)
                return
            }
            
            // If we have an unregistered channel for our host, we'll set the room id (because it is now registered)
            if let rid = response.responseData[Constants.Network.Json.result][Constants.Network.Json.rid].string {
                HostConnectionManager.shared.set(roomId: rid, forUnregisteredChannelIn: self.host)
            }
            
            completion(response)
        })
    }

    @discardableResult func loadHistory(for channel: Channel) -> Promise<Void> {
        return Promise { fulfill, reject in
            guard let rid = channel.roomId else {
                reject(HistoryError.noRoomNumberSet)
                return
            }
            
            let lastMessageDate = channel.lastMessage()?.date ?? Date(timeIntervalSinceNow: -31536000)
            
            let requestObject = [
                Constants.Network.Json.message: Constants.Network.Json.method,
                Constants.Network.Json.method: Constants.Network.Methods.loadHistory,
                Constants.Network.Json.params: [
                    rid,[Constants.Network.Json.date : Date.masaiTimestampFromDate(Date())] , 50, [Constants.Network.Json.date : Date.masaiTimestampFromDate(lastMessageDate)]]
                ] as [String: Any]
            
            send(requestObject) { (response) in
                print("load history response:\n\(response)")
                
                if let error = response.error,
                    error.errorCode == "error-invalid-room" {
                    reject(HistoryError.invalidRoom(roomId: rid))
                    return
                }
                
                guard response.errorOccured() == false else {
                    reject(HistoryError.errorOccurred)
                    return
                }
                
                for jsonMessage in response.responseData[Constants.Network.Json.result][Constants.Network.Json.messages].arrayValue {
                    let _ = MessageParser.parse(jsonMessage)
                }
                
                fulfill()
                
                Constants.Notification.historyLoaded(for: channel).post()
            }
        }
    }
    
    func getChannels(_ completion: @escaping GetChannelsClosure) {
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.getRooms,
            Constants.Network.Json.params: [
                host.liveChatToken
                ]
            ] as [String: Any]
        
        send(requestObject) { [unowned self] (response) in
            print("load channels response:\n\(response)")
            /*
             example response:
             {
                "id" : "sro3DVScSauQRIgzupaMo2bBfyk77kek83kWrqD2BpRFd73RLT",
                "result" : [
                {
                    "servedBy" : {
                        "_id" : "MAvdbPkN65niLMRtQ",
                        "username" : "Agent1"
                    },
                    "responseTime" : 9.1180000000000003,
                    "msgs" : 8,
                    "label" : "florian.rath",
                    "responseBy" : {
                        "_id" : "jHdQHLyrTgfb4Yp4w",
                        "username" : "guest-877"
                    },
                    "usernames" : [
                        "Agent1"
                    ],
                    "responseDate" : {
                        "$date" : 1510151269214
                    },
                    "_id" : "P3WFBLh6wuZCj4DuQ",
                    "code" : 930,
                    "lm" : {
                        "$date" : 1510156440020
                    },
                    "cl" : false,
                    "t" : "l",
                    "open" : true,
                    "meta" : {
                        "revision" : 9,
                        "created" : 1510151260104,
                        "updated" : 1510156440042,
                        "version" : 0
                    },
                    "username" : "guest-877",
                    "ts" : {
                        "$date" : 1510151260096
                    },
                    "$loki" : 147,
                    "v" : {
                        "_id" : "jHdQHLyrTgfb4Yp4w",
                        "username" : "guest-877",
                        "token" : "3bf1a755-6b06-4abd-a824-41e9f27702a5"
                    },
                    "_updatedAt" : {
                        "$date" : 1510156440039
                    }
                }
                ],
                "msg" : "result"
             }
             */
            
            guard response.errorOccured() == false else {
                return
            }
            
            guard let arr = response.responseData[Constants.Network.Json.result].array,
                arr.count > 0 else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
            }
            
            let usernameOnServer = arr[0][Constants.Network.Json.visitor][Constants.Network.Json.username].string
            
            HostConnectionManager.shared.credentials(forSocketUrl: self.host.socketUrl, completion: { (host: Host?, creds: LiveChatCredentials?) in
                // Update credentials with the new username if needed
                if var credentials = creds,
                    usernameOnServer != nil {
                    credentials.liveChatUsername = usernameOnServer!
                    HostConnectionManager.shared.update(credentials: credentials, for: self.host)
                }
                
                var channels: [Channel] = []
                for channelInfo in arr {
                    guard let roomId = channelInfo[Constants.Network.Json.identifier].string else {
                        continue
                    }
                    var c = Channel(name: self.host.name, roomId: roomId)
                    c.isClosed = (channelInfo[Constants.Network.Json.open].boolValue == false)
                    channels.append(c)
                }
                
                DispatchQueue.main.async {
                    completion(channels)
                }
            })
        }
    }
    
    func subscriptions(_ host: Host, completion: SubscriptionResponseCompletion? = nil) {
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.subscriptions,
            Constants.Network.Json.params: [
                [Constants.Network.Json.date: 0]
                ]
            ] as [String: Any]
        
        send(requestObject) { (response) in
            print("subscriptions response:\n\(response)")
            
            guard response.errorOccured() == false else {
                completion?(response, nil)
                return
            }
            
            var channels: [Channel] = []
            if let channelArray = response.responseData[Constants.Network.Json.result][Constants.Network.Json.update].array {
                for channelJson in channelArray {
                    let channel = Channel(channelJson)
                    channels.append(channel)
                }
                /* FIX for other json structure in response on different host */
            } else if let channelArray = response.responseData[Constants.Network.Json.result].array {
                for channelJson in channelArray {
                    let channel = Channel(channelJson)
                    channels.append(channel)
                }
            }
            /* --- */
            completion?(response, channels)
        }
    }
    
//    func createChannel(_ name: String, host: Host, completion: CreateChannelResponseCompletion? = nil) {
//        let requestObject = [
//            Constants.Network.Json.message: Constants.Network.Json.method,
//            Constants.Network.Json.method: Constants.Network.Methods.createChannel,
//            Constants.Network.Json.params: [
//                name,[], false
//            ]
//            ] as [String: Any]
//        send(requestObject) { (response) in
//            print("create channel response:\n\(response)")
//
//            guard response.errorOccured() == false else {
//                completion?(response, nil)
//                return
//            }
//
//            var createdChannel = Channel(response.responseData[Constants.Network.Json.result])
//            createdChannel.name = name
//            completion?(response, createdChannel)
//        }
//    }
    
//    func resetPass(for email: String, host: Host, completion:ResetPassResponsecCompletion?) {
//        let requestObject = [
//            Constants.Network.Json.message: Constants.Network.Json.method,
//            Constants.Network.Json.method: Constants.Network.Methods.resetPass,
//            Constants.Network.Json.params: [
//            email
//        ]] as [String: Any]
//
//        send(requestObject) { (response) in
//            print("reset pass response:\n\(response)")
//
//            guard response.errorOccured() == false else {
//                completion?(response, false)
//                return
//            }
//
//            let result = response.responseData[Constants.Network.Json.result].bool
//            completion?(response, result)
//        }
//    }
    
}
