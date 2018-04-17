//
//  HostAndChannelTests.swift
//  MasaiTests
//
//  Created by Florian Rath on 06.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import XCTest


class HostAndChannelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testChannelAdding() {
        var h = Host(url: "testurl", socketUrl: "testurl/socket:3001", name: "testhost", liveChatToken: "testlivechattoken", credentials: nil)
        
        let c1 = Channel(name: "testhost", roomId: "1")
        let c2 = Channel(name: "testhost", roomId: "2")
        let c3 = Channel(name: "testhost", roomId: "3")
        let c4 = Channel(name: "testhost", roomId: "1")
        
        XCTAssert(h.channels.count == 0)
        
        h.addOrReplace(channel: c1)
        XCTAssert(h.channels.count == 1)
        
        h.addOrReplace(channel: c2)
        XCTAssert(h.channels.count == 2)
        
        h.addOrReplace(channel: c3)
        XCTAssert(h.channels.count == 3)
        
        h.addOrReplace(channel: c4)
        XCTAssert(h.channels.count == 3)
        
        h.addOrReplace(channel: c1)
        XCTAssert(h.channels.count == 3)
        
        h.addOrReplace(channel: c2)
        XCTAssert(h.channels.count == 3)
    }
    
}
