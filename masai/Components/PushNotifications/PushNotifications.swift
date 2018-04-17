//
//  PushNotifications.swift
//  masai
//
//  Created by Florian Rath on 13.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications


class PushNotifications: NSObject {
    
    // MARK: Notifications
    
    static let deviceTokenReceived: Foundation.Notification = {
        let notificationName = Foundation.Notification.Name(rawValue: "PushNotifications.Notification.deviceTokenReceived")
        let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
        return note
    }()
    static func deviceTokenReceived(_ token: String) -> Foundation.Notification {
        var note = PushNotifications.deviceTokenReceived
        let userInfo: [AnyHashable: Any] = [
            "token": token
        ]
        note.userInfo = userInfo
        return note
    }
    
    
    // MARK: Properties
    
    var deviceToken: String?
    fileprivate(set) var existingPushRequest: PushOpenChatRequest?
    
    
    // MARK: Public
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    static func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            guard granted else {
                return
            }
            
            // User granted notifications, so we'll register for remote notifications
            PushNotifications.registerForRemoteNotifications()
        }
    }
    
    static func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings: UNNotificationSettings) in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func set(deviceTokenData deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        set(deviceToken: token)
    }
    
    func set(deviceToken newToken: String) {
        deviceToken = newToken
        NotificationCenter.default.post(PushNotifications.deviceTokenReceived(newToken))
    }
    
    func clearExistingPushRequest() {
        existingPushRequest = nil
    }
    
}


// MARK: UNUserNotificationCenterDelegate
extension PushNotifications: UNUserNotificationCenterDelegate {
    
    // Normal pushes / pushes while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // ejson string: {"host":"http://ec2-34-253-221-13.eu-west-1.compute.amazonaws.com:3001/","rid":"wndE6IDj1t5CEPa0p","sender":{"_id":"MAvdbPkN65niLMRtQ","username":"Agent1","name":"Agent"},"type":"l","name":""}
        
        let userInfo = notification.request.content.userInfo
        if let ejsonString = userInfo["ejson"] as? String,
            let jsonData = ejsonString.data(using: .utf8) {
            do {
                // We have got an ejson, so we'll try to read host and roomid from it
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                    let hostUrl = jsonObject["host"] as? String,
                    let roomId = jsonObject["rid"] as? String {
                    
                    // Check if we have an open room for the roomid
                    if !HostConnectionManager.shared.hasRoom(with: roomId),
                        let host = HostConnectionManager.shared.cachedHost(for: hostUrl) {
                        HostConnectionManager.shared.updateChannels(for: host)
                            .then { (_: SocketManager) in
                                Constants.Notification.newChannelFound.post()
                            }.catch(execute: { (error: Error) in
                                assert(false, "Could not update channels for host")
                                print("Could not update channels for host")
                            })
                    }
                }
            } catch {
                print("error: \(error)")
            }
        }
        
        completionHandler(UNNotificationPresentationOptions())
    }
    
    // Silent pushes / tapped normal pushes
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Debug
//        if let userInfoData = try? JSONSerialization.data(withJSONObject: response.notification.request.content.userInfo, options: .prettyPrinted),
//            let userInfoString = String(data: userInfoData, encoding: String.Encoding.utf8) {
//            print("payload: \(userInfoString)")
//        }
        
        let userInfo = response.notification.request.content.userInfo
        if let ejsonString = userInfo["ejson"] as? String,
            let jsonData = ejsonString.data(using: .utf8) {
            do {
                // We have got an ejson, so we'll try to read host and roomid from it
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                    let hostUrl = jsonObject["host"] as? String,
                    let roomId = jsonObject["rid"] as? String {
                    
                    existingPushRequest = PushOpenChatRequest(hostUrl: hostUrl, roomId: roomId)
                }
            } catch {
                print("error: \(error)")
            }
        }
        
        completionHandler()
    }
}
