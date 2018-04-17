//
//  LinkMessageDelegate.swift
//  masai
//
//  Created by Bartomiej Burzec on 08.05.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

protocol LinkMessageDelegate: class {
    func onLinkButtonPressed(url: String)
}
