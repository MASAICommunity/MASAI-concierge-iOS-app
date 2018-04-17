//
//  FormChecklistCell.swift
//  masai
//
//  Created by Florian Rath on 18.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


struct FormChecklistItemValue {
    let identifier: String
    let title: String
}

extension FormChecklistItemValue: Equatable {}
func ==(lhs: FormChecklistItemValue, rhs: FormChecklistItemValue) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.title == rhs.title
}


class FormChecklistCell: FormCell {
    
    // MARK: Properties
    
    var selectionValues: [FormChecklistItemValue] = []
    var selectedValues: [FormChecklistItemValue] = []
    
    
    // MARK: Lifecycle
    
    init(identifier: String, title: FormCellType.CellTitle, value: FormCellType.CellValue = nil, possibleValues: [FormChecklistItemValue], form: Form? = nil) {
        super.init(identifier: identifier, title: title, value: value, validator: nil, form: form)
        self.selectionValues = possibleValues
        
        for setIdentifier in (value as? [String] ?? []) {
            if let item = selectionValues.filter({ $0.identifier == setIdentifier }).first {
                selectedValues.append(item)
            }
        }
    }
    
    
    // MARK: View
    
    private var cellView: FormChecklistCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormChecklistCellView(cell: self, selectionValues: selectionValues, validator: validator)
        return cellView!
    }
    
    
    // MARK: Form evaluation
    
    override var values: [String: Any?]? {
        guard selectedValues.count > 0 else {
            return [identifier: nil]
        }
        
        let selectedDicts = selectedValues.map({ $0.identifier })
        return [identifier: selectedDicts]
    }
    
}
