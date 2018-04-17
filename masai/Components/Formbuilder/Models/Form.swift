//
//  Form.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class Form: FormType {
    
    // MARK: Types
    
    typealias UpdateSectionClosure = (_ section: FormSectionType) -> FormSectionType
    typealias CompletionClosure = () -> Void
    
    
    // MARK: Properties
    
    var sections: [FormSectionType]
    
    
    // MARK: Lifecycle
    
    init() {
        self.sections = []
    }
    
    
    // MARK: Public
    
    func add(section: FormSectionType) {
        sections.append(section)
    }
    
    func updateSection(withHeaderIdentifier headerIdentifier: String, updateClosure: UpdateSectionClosure, completionClosure: CompletionClosure? = nil) {
        let foundSections = sections.filter { $0.header.identifier == headerIdentifier }
        
        guard foundSections.count == 1 else {
            assert(false, "Too many or too few sections found!")
            return
        }
        
        let foundSection = foundSections.first!
        let index = sections.index { $0.header.identifier == foundSection.header.identifier }
        guard let foundIndex = index else {
            assert(false, "Could not find index for section to update")
            return
        }
        
        let updatedSection = updateClosure(foundSection)
        sections.remove(at: foundIndex)
        sections.insert(updatedSection, at: foundIndex)
        
        completionClosure?()
    }
    
    
    // MARK: View
    
    private var formView: FormView?
    
    func createView(forceRecreation: Bool = false) -> FormView {
        if let fv = formView,
            forceRecreation == false {
            return fv
        }
        
        formView = FormView(form: self)
        return formView!
    }
    
    
    // MARK: Form evaluation
    
    var values: FormDictionary {
        var dict: FormDictionary = [:]
        for section in sections {
            var existingSection = dict[section.header.identifier] ?? []
            existingSection.append(contentsOf: section.values)
            dict[section.header.identifier] = existingSection
        }
        return dict
    }
    
}
