//
//  FormCellType.swift
//  masai
//
//  Created by Florian Rath on 15.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


protocol FormCellType {
    
    typealias CellTitle = String
    typealias CellValue = Any?
    
    weak var form: Form? { get set }
    
    var identifier: String { get }
    var title: CellTitle { get }
    var value: CellValue { get set }
    
    func createView() -> FormCellView
    func createView(forceRecreation: Bool) -> FormCellView
    
    var values: [String: Any?]? { get }
    
    var textFieldType: ValidatableViewType.Type { get }
    
}



extension FormCellType {
    
    func createView() -> FormCellView {
        return createView(forceRecreation: false)
    }
    
}
