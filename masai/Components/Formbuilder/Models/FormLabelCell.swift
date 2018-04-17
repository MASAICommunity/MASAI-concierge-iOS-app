//
//  FormLabelCell.swift
//  masai
//
//  Created by Thomas Svitil on 06.09.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

class FormLabelCell: FormCell {

    // MARK: View
    
    private var cellView: FormLabelCellView?
    
    override func createView(forceRecreation: Bool) -> FormCellView {
        if let cv = cellView,
            forceRecreation == false {
            return cv
        }
        
        cellView = FormLabelCellView(cell: self)
        return cellView!
    }
}
