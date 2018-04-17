//
//  BaseDatabaseModel.swift
//  masai
//
//  Created by Bartomiej Burzec on 20.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public typealias UpdateBlock<T> = (_ object: T?) -> Void

protocol Updatable {
    func update(with json: JSON)
}

extension Updatable where Self: BaseDatabaseModel {
    
    static func getOrCreate(identifier: String?, jsonData: JSON, updates: UpdateBlock<Self>?) -> Self {
        var object: Self!
        
        Realm.execute {_ in
            if let key = identifier {
                if let storedObject  = try? Realm().object(ofType: Self.self, forPrimaryKey: key as AnyObject) {
                    object = storedObject
                }
            }
            
            if object == nil {
                object = Self()
            }
            
            object.update(with: jsonData)
            updates?(object)
        }
        return object
    }
    
}


public class BaseDatabaseModel: Object {
    dynamic var identifier: String?
    
    override public static func primaryKey() -> String? {
        return "identifier"
    }
}
