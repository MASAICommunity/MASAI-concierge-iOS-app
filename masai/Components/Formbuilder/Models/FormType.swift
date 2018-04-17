//
//  FormType.swift
//  masai
//
//  Created by Florian Rath on 15.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


protocol FormType {
    
    typealias FormDictionary = [FormSectionHeaderType.SectionTitle: [[String: Any?]]]
    
    
    var sections: [FormSectionType] { get set }
    
    func createView() -> FormView
    func createView(forceRecreation: Bool) -> FormView
    
    var values: FormDictionary { get }
}



extension FormType {
    
    func createView() -> FormView {
        return createView(forceRecreation: false)
    }
    
}
