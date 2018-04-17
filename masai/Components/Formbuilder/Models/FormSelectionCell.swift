//
//  FormSelectionCell.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


struct FormSelectionValue {
    let identifier: String
    let title: String
}


class FormSelectionCell: FormCell {
    
    // MARK: Properties
    
    var selectionValues: [FormSelectionValue] = []
    var sortValues = false
    
    
    // MARK: Lifecycle
    
    init(identifier: String, title: FormCellType.CellTitle, value: FormCellType.CellValue = nil, possibleValues: [FormSelectionValue], form: Form? = nil, sort: Bool) {
        let sanitizedValue = value ?? "-"
        
        super.init(identifier: identifier, title: title, value: sanitizedValue)
        self.selectionValues = possibleValues
        self.form = form
        self.sortValues = sort
    }
    
    
    // MARK: View
    
    private var cellView: FormSelectionCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormSelectionCellView(cell: self, selectionValues: selectionValues, validator: validator, sort: sortValues)
        return cellView!
    }
    
    
    // MARK: Public
    
    @discardableResult func set(disabled: Bool) -> FormSelectionCell {
        (createView() as! FormSelectionCellView).set(disabled: disabled)
        return self
    }
    
}
