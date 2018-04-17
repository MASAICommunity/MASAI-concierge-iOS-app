//
//  FormSection.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormSection: FormSectionType {
    
    // MARK: Properties
    
    let header: FormSectionHeaderType
    var cells: [FormCellType]
    
    
    // MARK: Lifecycle
    
    init(header: FormSectionHeaderType, cells: [FormCellType], form: Form? = nil) {
        self.header = header
        
        var cellsWithForm: [FormCellType] = []
        if let form = form {
            for cell in cells {
                var cellWithForm = cell
                cellWithForm.form = form
                cellsWithForm.append(cellWithForm)
            }
        }
        self.cells = cellsWithForm
    }
    
    
    // MARK: View
    
    private var sectionView: FormSectionView?
    
    func createView(formView: FormView, forceRecreation: Bool = false) -> UIView {
        if let sv = sectionView,
            forceRecreation == false {
            return sv
        }
        
        sectionView = FormSectionView(section: self, formView: formView)
        return sectionView!
    }
    
    
    // MARK: Form evaluation
    
    var values: [[String: Any?]] {
        var array: [[String: Any?]] = []
        for cell in cells {
            if let val = cell.values {
                array.append(val)
            }
        }
        return array
    }
    
}
