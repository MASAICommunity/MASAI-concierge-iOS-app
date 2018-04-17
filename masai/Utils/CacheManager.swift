//
//  CacheManager.swift
//  masai
//
//  Created by Bartłomiej Burzec on 07.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import Pantry
import Foundation

struct CacheManager {
    
    private static let photoDirectory = "/masai_cache_photo"
    
    static func saveLoggedUser(_ user: User) {
        Pantry.pack(user, key: Constants.Cache.user)
    }
    
    static func retrieveLoggedUser() -> User? {
        return Pantry.unpack(Constants.Cache.user)
    }
    
    static func retrieveUserProfile() -> UserProfile? {
        let profile: UserProfile? = Pantry.unpack(Constants.Cache.userProfile)
        return profile
    }
    
    static func save(userProfile: UserProfile) {
        Pantry.pack(userProfile, key: Constants.Cache.userProfile)
    }
    
    static func clearUserProfile() {
        Pantry.expire(Constants.Cache.userProfile)
    }
    
    static func removeLoggedUser() {
        Pantry.expire(Constants.Cache.user)
    }
    
    static func saveHosts(_ hosts: [Host]) {
        var cleanedHosts: [Host] = []
        for host in hosts {
            var updatedHost = host
            updatedHost.cleanupUnregisteredChannels()
            cleanedHosts.append(updatedHost)
        }
        Pantry.pack(cleanedHosts, key: Constants.Cache.hosts)
    }
    
    static func retrieveHosts() -> [Host] {
        let hosts: [Host] = Pantry.unpack(Constants.Cache.hosts) ?? []
        return hosts
    }
    
    private static func imagesDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectorPath:String = paths[0]
        
        return "\(documentDirectorPath)\(photoDirectory)"
    }
    
    private static func path(_ filename: String) -> String {
        var fullFilename = filename
        if !(fullFilename.hasSuffix(".jpg") || fullFilename.hasSuffix(".JPG")) {
            fullFilename += ".jpg"
        }
        return "\(imagesDirectoryPath())/\(fullFilename)"
    }
    
    
    static func cacheImage(_ data: Data, filename: String) {
        var objcBool =  ObjCBool(true)
        if FileManager.default.fileExists(atPath: imagesDirectoryPath(), isDirectory: &objcBool) == false {
            do {
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath(), withIntermediateDirectories: true, attributes: nil)
                //TODO: exlude from iCloud backup
            }  catch _ {
                print("failed_to_create_img_folder".localized)
            }
        }
        
        let imagePath = path(filename)
        
        let didSucceed = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        assert(didSucceed, "Failed! not cache image!")
    }
    
    static func cacheImage(_ image: UIImage, filename: String) {
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            cacheImage(imageData, filename: filename)
        }
    }
    
    static func cachedImage(_ filename: String) -> UIImage? {
        if let data = FileManager.default.contents(atPath: path(filename)) {
            return UIImage(data: data)
        }
        return nil
    }
    
    static func removeCachedImage(_ filename: String) {
        do {
           try FileManager.default.removeItem(atPath: path(filename))
        } catch _ {
            print("failed_to_delete_img".localized)
        }
    }
    
}
