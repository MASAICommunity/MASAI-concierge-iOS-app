//
//  UITextField+ValidatableViewType.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


extension UITextField: ValidatableViewType {
    
    static func createInstance() -> UIView {
        return self.init()
    }
    
    var view: UIView {
        return self
    }
    
    func setValid() {}
    func setInvalid() {}
    
}
