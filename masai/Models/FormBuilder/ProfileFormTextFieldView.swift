//
//  ProfileFormTextFieldView.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileFormTextFieldView: UIView, ValidatableViewType {
    
    var textField: ProfileTextField?
    
    static func createInstance() -> UIView {
        return ProfileTextField()
    }
    
    var view: UIView {
        return self
    }
    
    func setValid() {}
    
    func setInvalid() {}
    
}
