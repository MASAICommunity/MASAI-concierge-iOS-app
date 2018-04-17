//
//  FormCell.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormCell: FormCellType {
    
    // MARK: Properties
    
    weak var form: Form?
    
    let identifier: String
    let title: FormCellType.CellTitle
    var value: FormCellType.CellValue
    
    var validator: ValidatorType?
    var transformator: TransformatorType?
    
    
    // MARK: Lifecycle
    
    init(identifier: String, title: FormCellType.CellTitle, value: FormCellType.CellValue = nil, validator: ValidatorType? = nil, transformator: TransformatorType? = nil, form: Form? = nil) {
        self.identifier = identifier
        self.title = title
        self.value = value
        self.validator = validator
        self.form = form
        self.transformator = transformator
    }
    
    
    // MARK: View
    
    func createView(forceRecreation: Bool) -> FormCellView {
        return FormCellView()
    }
    
    
    // MARK: Form evaluation
    
    var values: [String: Any?]? {
        if let val = validator,
            !val.isValid(value: value as? String) {
            return nil
        }
        
        return [identifier: value]
    }
    
    
    // MARK: Dependency Injection
    
    var textFieldType: ValidatableViewType.Type {
        return UITextField.self
    }
    
}
