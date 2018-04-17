//
//  ChatMessage.swift
//  masai
//
//  Created by Bartłomiej Burzec on 08.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import SwiftyJSON
import Foundation
import RealmSwift

enum ChatMessageStatus {
    case failed, sending, sent
}

public class ChatMessage: BaseDatabaseModel {
    dynamic var rid: String?
    dynamic var id: String?
    dynamic var messageText: String?
    dynamic var date: Date?
    dynamic var updated: Date?
    dynamic var username: String?
    dynamic var sending = false
    dynamic var sent = false
    dynamic var imageAttached = false
    dynamic var imageStoredLocally = false
    dynamic var googlePlacesAttached = false
    dynamic var locationAttached = false
    dynamic var linkAttached = false
    dynamic var fileAttached = false
    
    var isCloseChannelMessage: Bool {
        if messageText == SocketResponseMessageType.CloseChannel.rawValue {
            return true
        }
        return false
    }
    
    dynamic var linkDescription: String?
    dynamic var linkTitle: String?
    dynamic var linkHost: String?
    dynamic var linkImageUrl: String?
    dynamic var linkUrl: String?
    
    dynamic var imageIdentifier: String?
    dynamic var imageLink: String?
    dynamic var imageName: String?
    
    dynamic var latitude = Double.greatestFiniteMagnitude
    dynamic var longitude = Double.greatestFiniteMagnitude
    dynamic var locationName: String?
    
    dynamic var attachmentTitle: String?
    dynamic var attachmentLink: String?
    dynamic var attachmentDescription: String?
    
    dynamic var isPermission = false
    dynamic var permissionLink: String?
    dynamic var permissionPayload: String?
    dynamic var permissionConfirmed = false
    
    dynamic var isPermissionAnswer = false
    dynamic var permissionAnswerGranted =  false
    
    let googlePlaces = List<GooglePlace>()
    
    var messageWithoutUrls: String {
        get {
            if let text = self.messageText {
                return text.removeURLs()
            }
            return ""
        }
    }
    
    var message: String {
        get {
            if let text = self.messageText{
                return Emoji.transform(string: text)
            }
            return ""
        }
    }
    
    var status: ChatMessageStatus {
        get {
            if self.sent {
                return .sent
            } else if self.sending {
                return .sending
            }
            return .failed
        }
    }
    
    var attachmentFileName: String? {
        get {
            if let title = self.attachmentTitle {
                return title.replacingOccurrences(of: "File Uploaded: ", with: "")
            }
            return nil
        }
    }
    
    var attachmentText: String {
        get {
            var descriptionText = ""
            if let filename = self.attachmentTitle {
                descriptionText += filename
            }
            if let description = self.attachmentDescription {
                descriptionText += "   " + description
            }
            return descriptionText
        }
    }
    
    static func messageForImageUpdate(_ channelRid: String, imageName: String) -> ChatMessage? {
        guard let message = try? Realm().objects(ChatMessage.self).filter("rid == %@ && imageName == %@", channelRid, imageName).last else {
            return nil
        }
        return message
    }
}

extension ChatMessage: ChatData {
    func dataType() -> ChatDataType {
        if googlePlacesAttached {
            return .googlePlaces
        }
        
        if locationAttached {
            return .location
        }
        
        if imageAttached {
            return .image
        }
        
        if isPermissionAnswer {
            return .permissionAnswer
        }
        
        if isPermission {
            return .permission
        }
        
        if linkAttached {
            return .link
        }
        
        if fileAttached {
            return .attachment
        }
        
        if isCloseChannelMessage {
            return .closeChannelMessage
        }
        
        return .message
    }
}

extension ChatMessage: Updatable {
    func update(with json: JSON) {
        self.rid = json[Constants.Network.Json.rid].string
        self.id = json[Constants.Network.Json.identifier].string
        self.messageText = json[Constants.Network.Json.message].string
        self.date = Date.dateFromMasaiTimestamp(json[Constants.Network.Json.timestamp][Constants.Network.Json.date].double)
        self.updated = Date.dateFromMasaiTimestamp(json[Constants.Network.Json.updated][Constants.Network.Json.date].double)
        self.username = json[Constants.Network.Json.userInfo][Constants.Network.Json.username].string
        self.imageLink = json[Constants.Network.Json.attachments][0][Constants.Network.Json.imageURL].string
        
        if let long = json[Constants.Network.Json.location][Constants.Network.Json.coordinates][0].double, let lat = json[Constants.Network.Json.location][Constants.Network.Json.coordinates][1].double {
         
            self.longitude = long
            self.latitude = lat
            self.locationAttached = true
        }
        
        if json[Constants.Network.Json.urls].exists() {
            self.linkAttached = true
            let urlJson = json[Constants.Network.Json.urls][0]
            self.linkDescription = urlJson[Constants.Network.Json.meta][Constants.Network.Json.description].string
            self.linkTitle = urlJson[Constants.Network.Json.meta][Constants.Network.Json.pageTitle].string
            self.linkImageUrl = urlJson[Constants.Network.Json.meta][Constants.Network.Json.pageImage].string
            self.linkHost = urlJson[Constants.Network.Json.parsedUrl][Constants.Network.Json.host].string
            self.linkUrl = urlJson[Constants.Network.Json.url].string
        }
        
        if json[Constants.Network.Json.attachments].exists() {
            self.fileAttached = true
            let attachmentJson = json[Constants.Network.Json.attachments][0]
            self.attachmentTitle = attachmentJson[Constants.Network.Json.title].string
            self.attachmentLink = attachmentJson[Constants.Network.Json.titleLink].string
            self.attachmentDescription = attachmentJson[Constants.Network.Json.description].string
        }
        
        if self.identifier == nil {
            self.identifier = self.id
        }
        
        if self.imageLink != nil {
            self.imageAttached = true
        }
        
    }
}

