//
//  FormCellView.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormTextCellView: FormCellView {
    
    // MARK: Properties
    
    fileprivate var cell: FormCellType?
    
    
    // MARK: UI elements
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.heightAnchor.constraint(equalToConstant: 15).isActive = true
        l.font = UIFont.systemFont(ofSize: 8)
        l.textColor = UIColor(red: 147/255.0, green: 147/255.0, blue: 147/255.0, alpha: 1.0)
        return l
    }()
    
    private var textField: UITextField!
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType, validator: ValidatorType?, transformator: TransformatorType?) {
        self.init(frame: .zero)
        
        self.cell = cell
        self.validator = validator
        self.transformator = transformator
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        setup()
        
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        guard let cell = cell else {
            return
        }
        
        addSubview(label)
        label.pin.edges([.leading, .top, .trailing]).to(self).with(constants: [0, 4, 0]).activate()
        label.text = cell.title
        
        textField = createTextField()
        addSubview(textField)
        textField.pin.top.to(label.bottomAnchor).with(0).activate()
        textField.pin.edges([.leading, .bottom, .trailing]).to(self).activate()
        textField.text = cell.value as? String
        
        textField.delegate = self
        
        if let val = validator,
            val.validateImmediately == true {
            validate()
        }
    }
    
    private func createTextField() -> UITextField {
        let t = cell!.textFieldType.createInstance()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t as! UITextField
    }
    
    
    // MARK: Validation
    
    fileprivate func validate() {
        if let val = validator,
            let cell = cell {
            let isValid = val.isValid(value: cell.value as? String)
            if isValid {
                set(validationState: .valid)
            } else {
                set(validationState: .invalid)
            }
        }
    }
    
    override func set(validationState: FormCellView.ValidationState) {
        super.set(validationState: validationState)
        
        switch validationState {
        case .valid:
            textField.setValid()
        case .invalid:
            textField.setInvalid()
        }
    }
    
    
    // MARK: Public
    
    func set(disabled: Bool) {
        textField.isEnabled = !disabled
    }
    
}


// MARK: UITextFieldDelegate
extension FormTextCellView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        if cell != nil {
            cell!.value = newString
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Transform value
        if let t = transformator {
            let transformedValue = t.transform(value: textField.text)
            textField.text = transformedValue as? String
            cell?.value = transformedValue
        }
        
        // Validate value
        validate()
        
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (cell?.form ?? nil) as Any])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
