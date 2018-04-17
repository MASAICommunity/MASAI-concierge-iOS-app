//
//  FormCellView.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormCellView: UIView {
    
    // MARK: Validation
    
    internal var validator: ValidatorType?
    internal var transformator: TransformatorType?
    
    enum ValidationState {
        case valid
        case invalid
    }
    
    public private(set) var validationState = ValidationState.valid
    
    func set(validationState: ValidationState) {
        self.validationState = validationState
    }
    
}
