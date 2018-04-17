//
//  ValidatableViewType.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


protocol ValidatableViewType {
    
    static func createInstance() -> UIView
    var view: UIView { get }
    func setValid()
    func setInvalid()
    
}
