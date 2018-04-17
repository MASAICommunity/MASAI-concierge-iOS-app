//
//  UploadManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 23.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import RealmSwift

public typealias UploadProgressBlock = (Int) -> Void
public typealias UploadCompletionBlock = (SocketResponseMessage?, Bool) -> Void
public typealias UploadMessageBlock = (ChatMessage) -> Void

class UploadManager  {
    
    private init() {}
    
    static let sharedInstance = UploadManager()
    
    fileprivate func sendSummaryUploadMessage(_ parameters: [Any], host: Host, completion: UploadCompletionBlock?) {
        
        let requestObject: [String: Any] = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.sendFileMessage,
            Constants.Network.Json.params: parameters]
        
        guard let socketManager = HostConnectionManager.shared.existingConnections[host] else {
            completion?(nil, false)
            return
        }
    
        socketManager.send(requestObject) { (response) in
            completion?(response, !response.errorOccured())
        }
    }
    
    fileprivate func uploadRequest(_ url: URL, file: FileForUpload, formData: JSON) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = String.random()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())
        
        for postData in formData.array ?? [] {
            guard let key = postData[Constants.Network.Json.name].string else { continue }
            guard let value = postData[Constants.Network.Json.value].string else { continue }
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
            data.append(value.data(using: .utf8) ?? Data())
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())
        }
        
        data.append("Content-Disposition: form-data; name=\"file\"\r\n".data(using: .utf8) ?? Data())
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) ?? Data())
        data.append(file.data)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        request.httpBody = data
        return request
    }
    
    fileprivate func uploadProccess(_ file: FileForUpload, requestObject: [String: Any], host: Host, rid: String, completion: UploadCompletionBlock?) {
        guard let socketManager = HostConnectionManager.shared.existingConnections[host] else {
            completion?(nil, false)
            return
        }
        
        socketManager.send(requestObject, completionResponse: { (response) in
            guard response.errorOccured() == false else {
                DispatchQueue.main.async {
                    completion?(response, false)
                }
                return
            }
            
            let responseData = response.responseData
            guard let uploadURL = URL(string: responseData[Constants.Network.Json.result][Constants.Network.Json.upload].string ?? ""), let downloadLink = responseData[Constants.Network.Json.result][Constants.Network.Json.download].string  else {
                DispatchQueue.main.async {
                    completion?(nil, false)
                }
                return
            }
            
            let formData = responseData[Constants.Network.Json.result][Constants.Network.Json.postData]
            let request = self.uploadRequest(uploadURL, file: file, formData: formData)
            
            Alamofire.request(request).responseString(completionHandler: { (response) in
                if let _ = response.value {
                    let fileIdentifier = downloadLink.components(separatedBy: "/").last ?? String.random()
                    
                    let params: [Any] = [rid, Constants.Network.Json.s3, [
                        Constants.Network.Json.type: file.type,
                        Constants.Network.Json.size: file.size,
                        Constants.Network.Json.name: file.name,
                        Constants.Network.Json.identifier: fileIdentifier,
                        Constants.Network.Json.url: downloadLink
                        ]]
                    
                    self.sendSummaryUploadMessage(params, host: host, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion?(nil, false)
                    }
                }
            })
        })
    }
    
    func upload(file: FileForUpload, channel: Channel, messageReceiver: @escaping UploadMessageBlock, completion: @escaping UploadCompletionBlock, progress: UploadProgressBlock? = nil) {
        
        HostConnectionManager.shared.host(for: channel) { [unowned self] (host: Host?) in
            guard let host = host,
                let rid = channel.roomId,
                let socketManager = HostConnectionManager.shared.socketManager(for: host) else {
                DispatchQueue.main.async {
                    completion(nil, false)
                }
                return
            }
            
            let requestObject: [String: Any] = [
                Constants.Network.Json.message: Constants.Network.Json.method,
                Constants.Network.Json.method: Constants.Network.Methods.upload,
                Constants.Network.Json.params: [Constants.Network.Json.rocketUpload,
                                                [Constants.Network.Json.name: file.name,
                                                 Constants.Network.Json.size: file.size,
                                                 Constants.Network.Json.type: file.type],
                                                [Constants.Network.Json.rid: rid]]]
            
            CacheManager.cacheImage(file.data, filename: file.name)
            
            let newMessage = ChatMessage()
            newMessage.identifier = String.random(length:18) // temporary identifier
            newMessage.messageText = ""
            newMessage.imageAttached = true
            newMessage.imageStoredLocally = true
            newMessage.sending = socketManager.isConnected(with: host)
            newMessage.rid = rid
            newMessage.imageName = file.name
            newMessage.username = host.credentials?.liveChatUsername
            newMessage.date = Date()
            
            Realm.execute({ (realm) in
                realm.add(newMessage)
            })
            
            messageReceiver(newMessage)
            self.uploadProccess(file, requestObject: requestObject, host: host, rid: rid, completion: completion)
        }
    }
    
    
    func reupload(channel: Channel, message: ChatMessage) {
        HostConnectionManager.shared.host(for: channel) { [unowned self] (host: Host?) in
            guard let host = host else {
                //TODO: throw an error here?
                return
            }
            
            guard let rid = channel.roomId,
                let imageName = message.imageName,
                let image = CacheManager.cachedImage(imageName),
                let imageData = UIImageJPEGRepresentation(image, 0.9) else {
                    return
            }
            
            let file = FileForUpload(
                name: imageName,
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )
            
            let requestObject: [String: Any] = [
                Constants.Network.Json.message: Constants.Network.Json.method,
                Constants.Network.Json.method: Constants.Network.Methods.upload,
                Constants.Network.Json.params: [Constants.Network.Json.rocketUpload,
                                                [Constants.Network.Json.name: file.name,
                                                 Constants.Network.Json.size: file.size,
                                                 Constants.Network.Json.type: file.type],
                                                [Constants.Network.Json.rid: rid]]]
            
            self.uploadProccess(file, requestObject: requestObject, host: host, rid: rid, completion: nil)
        }
    }
    
}

