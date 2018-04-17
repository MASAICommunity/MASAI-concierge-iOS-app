//
//  FormSelectionCellView.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormSelectionCellView: FormCellView {
    
    // MARK: Properties
    
    fileprivate var cell: FormCellType?
    fileprivate var selectionValues: [FormSelectionValue] = []
    var sortValues = false
    
    
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
    
    private var picker: UIPickerView!
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType, selectionValues: [FormSelectionValue], validator: ValidatorType?, sort: Bool) {
        self.init(frame: .zero)
        
        self.cell = cell
        self.selectionValues = selectionValues
        self.validator = validator
        self.sortValues = sort
        
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
        
        if sortValues {
            // Sort values alphabethically in current Language
            selectionValues.sort(by: { (val1, val2) -> Bool in
                // Default value (= "-") should be on top of all other identifiers, regardless of its title
                if val1.identifier == "-" {
                    return true
                } else if val2.identifier == "-" {
                    return false
                }
                
                // Since we don't have a default value, we'll sort by title
                return val1.title < val2.title
            })
        }
        
        addSubview(label)
        label.pin.edges([.leading, .top, .trailing]).to(self).with(constants: [0, 4, 0]).activate()
        label.text = cell.title
        
        textField = createTextField()
        addSubview(textField)
        textField.pin.top.to(label.bottomAnchor).with(0).activate()
        textField.pin.edges([.leading, .bottom, .trailing]).to(self).activate()
        textField.text = titleFor(value: (cell.value as? String))
        
        textField.delegate = self
        
        resetPicker()
    }
    
    private func createTextField() -> UITextField {
        let t = cell!.textFieldType.createInstance()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t as! UITextField
    }
    
    private func titleFor(value: String?) -> String? {
        guard let val = value else {
            return nil
        }
        let filtered = selectionValues.filter({ $0.identifier == val })
        return filtered.first?.title
    }
    
    fileprivate func valueFor(title: String?) -> String? {
        guard let title = title else {
            return nil
        }
        let filtered = selectionValues.filter({ $0.title == title })
        return filtered.first?.identifier
    }
    
    fileprivate func selectFirstItem() {
        let firstItemTitle = selectionValues.first!.title
        textField.text = firstItemTitle
        cell?.value = valueFor(title: firstItemTitle)
    }
    
    fileprivate func resetPicker() {
        picker = UIPickerView()
        picker.delegate = self
        textField.inputView = picker
    }
    
    
    // MARK: Public
    
    func set(disabled: Bool) {
        textField.isEnabled = !disabled
    }
    
}


// MARK: UITextFieldDelegate
extension FormSelectionCellView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        if cell != nil {
            let identifier = valueFor(title: newString)
            cell!.value = identifier
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (cell?.form ?? nil) as Any])
        resetPicker()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectFirstItem()
        return true
    }
    
}


// MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension FormSelectionCellView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectionValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectionValues[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = selectionValues[row].title
        
        if cell != nil {
            let identifier = valueFor(title: textField.text)
            cell!.value = identifier
        }
    }
    
}
