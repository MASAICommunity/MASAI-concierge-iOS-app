//
//  ChatCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import UIKit

protocol ChatCell {
    static func calculateHeight(for message: ChatMessage) -> CGFloat
}
