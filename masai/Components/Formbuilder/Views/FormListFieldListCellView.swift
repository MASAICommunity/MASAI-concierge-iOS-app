//
//  FormListFieldListCellView.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormListFieldListCellView: FormCellView {
    
    // MARK: Properties
    
    fileprivate var cell: FormListFieldListCell?
    fileprivate var selectionValues: [FormListFieldItemValue] = []
    
    
    // MARK: UI elements
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.heightAnchor.constraint(equalToConstant: 15).isActive = true
        l.font = UIFont.systemFont(ofSize: 8)
        l.textColor = UIColor(red: 147/255.0, green: 147/255.0, blue: 147/255.0, alpha: 1.0)
        return l
    }()
    
    private let contentLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 10)
        return l
    }()
    
    private let clearButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(#imageLiteral(resourceName: "ic_message_failed").withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = .black
        b.addTarget(self, action: #selector(FormListFieldListCellView.clearButtonPressed(_:)), for: .touchUpInside)
        return b
    }()
    
    fileprivate var selectionTextField: UITextField!
    private var numberTextField: UITextField!
    private var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        b.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        b.setTitle("form_list_addbutton".localized, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        b.backgroundColor = UIColor.dbRed
        b.layer.cornerRadius = 4.0
        b.setTitleColor(UIColor.white, for: .normal)
        return b
    }()
    
    private let picker: UIPickerView = {
        let p = UIPickerView()
        return p
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType, selectionValues: [FormListFieldItemValue], validator: ValidatorType?) {
        self.init(frame: .zero)
        
        self.cell = (cell as! FormListFieldListCell)
        self.selectionValues = selectionValues
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
        
        addSubview(contentLabel)
        contentLabel.pin.top.to(label.bottomAnchor).with(4).activate()
        contentLabel.pin.edges([.leading, .trailing]).to(self).activate()
        
        addSubview(clearButton)
        clearButton.pin.top.to(label.bottomAnchor).with(4).activate()
        clearButton.pin.edges([.trailing]).to(self).activate()
        
        selectionTextField = createTextField()
        selectionTextField.tintColor = .clear
        selectionTextField.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        selectionTextField.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        addSubview(selectionTextField)
        selectionTextField.pin.top.to(contentLabel.bottomAnchor).activate()
        selectionTextField.pin.edges([ .leading, .bottom ]).to(self).activate()
        selectionTextField.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        selectionTextField.text = selectionValues.first?.title
        
        numberTextField = createTextField()
        addSubview(numberTextField)
        numberTextField.pin.edges([.top, .bottom]).to(selectionTextField).activate()
        numberTextField.pin.leading.to(selectionTextField.trailingAnchor).with(4).activate()
        numberTextField.placeholder = "form_list_number_field_placeholder".localized        
        addSubview(addButton)
        addButton.pin.edges([.top, .bottom]).to(selectionTextField).activate()
        addButton.pin.leading.to(numberTextField.trailingAnchor).with(4).activate()
        addButton.pin.trailing.to(self).activate()
        
        selectionTextField.delegate = self
        numberTextField.delegate = self
        
        picker.delegate = self
        selectionTextField.inputView = picker
        
        addButton.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
        
        updateLabel()
    }
    
    private func createTextField() -> UITextField {
        let t = cell!.textFieldType.createInstance()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t as! UITextField
    }
    
    
    // MARK: Private
    
    private func updateLabel() {
        guard let cell = cell else {
            return
        }
        
        clearButton.isHidden = true
        var labelString = ""
        for val in cell.specifiedValues {
            labelString += "\(val.title): \((val.value ?? ""))\n"
            clearButton.isHidden = false
        }
        contentLabel.text = labelString
    }
    
    private func set(value: FormListFieldItemValue) {
        guard let cell = cell else {
            return
        }
        
        if cell.specifiedValues.contains(value) {
            cell.specifiedValues.remove(value)
        }
        cell.specifiedValues.insert(value)
        
        updateLabel()
    }
    
    
    // MARK: UI events
    
    @objc private func buttonPressed(_ sender: UIButton) {
        guard let number = numberTextField.text,
            number.characters.count > 0 else {
            return
        }
        
        let filteredValues = selectionValues.filter { [unowned self] (itemValue) -> Bool in
            return itemValue.title == self.selectionTextField.text
        }
        assert(filteredValues.count == 1)
        
        var value = filteredValues.first!
        value.value = number
        set(value: value)
        
        numberTextField.text = nil
        self.endEditing(true)
        
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (cell?.form ?? nil) as Any])
    }
    
    @objc private func clearButtonPressed(_ sender: UIButton) {
        
        guard let cell = cell else {
            return
        }
        
        cell.specifiedValues.removeAll()
        updateLabel()
        
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (self.cell?.form ?? nil) as Any])
    }
}


// MARK: UITextFieldDelegate
extension FormListFieldListCellView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


// MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension FormListFieldListCellView: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        selectionTextField.text = selectionValues[row].title
    }
    
}
