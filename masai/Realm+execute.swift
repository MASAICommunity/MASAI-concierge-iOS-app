//
//  Realm+execute.swift
//  masai
//
//  Created by Bartomiej Burzec on 20.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import RealmSwift
import Foundation

var executingRealmInstance: Realm?

extension Realm {
    
    static func execute(_ completion: (Realm) -> Void) {
        if let realm = executingRealmInstance {
            completion(realm)
            return
        }
        
        guard let realm = try? Realm() else { return }
        executingRealmInstance = realm
        try? realm.write {
            completion(realm)
        }
        executingRealmInstance = nil
    }
    
    static func update(_ object: Object) {
        self.execute { realm in
            realm.add(object, update: true)
        }
    }
    
    static func update<S: Sequence>(_ objects: S) where S.Iterator.Element: Object {
        self.execute { realm in
            realm.add(objects, update: true)
        }
    }

}
