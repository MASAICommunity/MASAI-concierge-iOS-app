//
//  FormSectionType.swift
//  masai
//
//  Created by Florian Rath on 15.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


protocol FormSectionType {
    
    var header: FormSectionHeaderType { get }
    var cells: [FormCellType] { get set }
    
    func createView(formView: FormView) -> UIView
    func createView(formView: FormView, forceRecreation: Bool) -> UIView
    
    var values: [[String: Any?]] { get }
    
}



extension FormSectionType {
    
    func createView(formView: FormView) -> UIView {
        return createView(formView: formView, forceRecreation: false)
    }
    
}
