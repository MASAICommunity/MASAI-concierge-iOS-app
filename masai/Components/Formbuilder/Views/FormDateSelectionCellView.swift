//
//  FormDateSelectionCellView.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormDateSelectionCellView: FormCellView {
    
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
    
    fileprivate var textField: UITextField!
    
    private let picker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .date
        return p
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType, validator: ValidatorType?) {
        self.init(frame: .zero)
        
        self.cell = cell
        self.validator = validator
        
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
        
        picker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
        textField.inputView = picker
    }
    
    private func createTextField() -> UITextField {
        let t = cell!.textFieldType.createInstance()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t as! UITextField
    }
    
    
    // MARK: Public
    
    static func dateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        return df
    }
    
    
    // MARK: DatePicker
    
    func datePickerChanged(_ sender: UIDatePicker) {
        let date = sender.date
        let dateString = FormDateSelectionCellView.dateFormatter().string(from: date)
        textField.text = dateString
        
        if cell != nil {
            cell!.value = textField.text
        }
    }
    
}


// MARK: UITextFieldDelegate
extension FormDateSelectionCellView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        if cell != nil {
            cell!.value = newString
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (cell?.form ?? nil) as Any])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
