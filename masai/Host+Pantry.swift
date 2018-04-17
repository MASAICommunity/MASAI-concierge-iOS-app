//
//  Host+Pantry.swift
//  masai
//
//  Created by Florian Rath on 06.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Pantry


extension Host: Storable {
    
    init?(warehouse: Warehouseable) {
        self.url = warehouse.get("url")!
        self.socketUrl = warehouse.get("socketUrl")!
        self.name = warehouse.get("name")!
        self.liveChatToken = warehouse.get("liveChatToken")!
        self.channels = warehouse.get("channels") ?? []
        self.credentials = warehouse.get("credentials")
        self.isActive = warehouse.get("isActive") ?? true
    }
    
}
