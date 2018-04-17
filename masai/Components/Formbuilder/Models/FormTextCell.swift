//
//  FormCell.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormTextCell: FormCell {
    
    // MARK: View
    
    private var cellView: FormTextCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormTextCellView(cell: self, validator: validator, transformator: transformator)
        return cellView!
    }
    
    
    // MARK: Public
    
    @discardableResult func set(disabled: Bool) -> FormTextCell {
        (createView() as! FormTextCellView).set(disabled: disabled)
        return self
    }
    
}
