//
//  Channel+Pantry.swift
//  masai
//
//  Created by Florian Rath on 06.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Pantry


extension Channel: Storable {
    
    init?(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? ""
        self.roomId = warehouse.get("roomId")
        self.isClosed = warehouse.get("isClosed") ?? false
    }
    
}
