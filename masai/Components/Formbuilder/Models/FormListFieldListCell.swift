//
//  FormListFieldListCell.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


struct FormListFieldItemValue {
    let identifier: String
    let title: String
    var value: String? = nil
    
    init(identifier: String, title: String) {
        self.identifier = identifier
        self.title = title
    }
    
    init(identifier: String, title: String, value: String) {
        self.init(identifier: identifier, title: title)
        self.value = value
    }
}

extension FormListFieldItemValue: Hashable {
    var hashValue: Int {
        return identifier.hashValue ^ title.hashValue
    }
    
    static func == (lhs: FormListFieldItemValue, rhs: FormListFieldItemValue) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.title == rhs.title
    }
}


class FormListFieldListCell: FormCell {
    
    // MARK: Properties
    
    var selectionValues: [FormListFieldItemValue] = []
    var specifiedValues = Set<FormListFieldItemValue>()
    
    
    // MARK: Lifecycle
    
    init(identifier: String, title: FormCellType.CellTitle, value: FormCellType.CellValue = nil, possibleValues: [FormListFieldItemValue], form: Form? = nil) {
        super.init(identifier: identifier, title: title, value: value)
        self.selectionValues = possibleValues
        self.form = form
        
        if let entries = value as? [LoyaltyProgramEntry]? {
            for entry in (entries ?? []) {
                if var foundSelectionValue = selectionValues.filter({ $0.identifier == entry.identifier }).first {
                    foundSelectionValue.value = entry.value
                    specifiedValues.insert(foundSelectionValue)
                }
            }
        } else {
            assert(false, "Could not infer value type!")
        }
    }
    
    
    // MARK: View
    
    private var cellView: FormListFieldListCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormListFieldListCellView(cell: self, selectionValues: selectionValues, validator: validator)
        return cellView!
    }
    
    
    // MARK: Form evaluation
    
    override var values: [String : Any?]? {
        guard specifiedValues.count > 0 else {
            return [identifier: nil]
        }
        
        var valueDict: [String: String] = [:]
        for value in specifiedValues where value.value != nil {
            valueDict[value.identifier] = value.value
        }
        return [identifier: valueDict]
    }
    
}
