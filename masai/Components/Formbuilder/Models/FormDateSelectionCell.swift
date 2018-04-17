//
//  FormDateSelectionCell.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormDateSelectionCell: FormCell {
    
    // MARK: View
    
    private var cellView: FormDateSelectionCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormDateSelectionCellView(cell: self, validator: validator)
        return cellView!
    }
    
}

