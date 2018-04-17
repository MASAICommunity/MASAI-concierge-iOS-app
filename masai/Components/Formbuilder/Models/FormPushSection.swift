//
//  FormPushSection.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormPushSection: FormSectionType {
    
    // MARK: Types
    
    typealias DidTapClosure = ((_ section: FormPushSection)->Void)
    
    
    // MARK: Properties
    
    let header: FormSectionHeaderType
    var cells: [FormCellType] = []
    var didTapClosure: DidTapClosure?
    
    // MARK: Lifecycle
    
    init(header: FormSectionHeaderType, form: Form? = nil, didTapClosure: DidTapClosure?) {
        self.header = header
        self.didTapClosure = didTapClosure
    }
    
    
    // MARK: Public
    
    func setAlertHighlighted(_ shouldSet: Bool) {
        guard let view = sectionView else {
            assert(false, "Section view was not yet initialized!")
            return
        }
        
        view.setAlertHighlighted(shouldSet)
    }
    
    
    // MARK: View
    
    private var sectionView: FormPushSectionView?
    
    func createView(formView: FormView, forceRecreation: Bool = false) -> UIView {
        if let sv = sectionView,
            forceRecreation == false {
            return sv
        }
        
        sectionView = FormPushSectionView(section: self, formView: formView, didTapClosure: didTapClosure)
        return sectionView!
    }
    
    
    // MARK: Form evaluation
    
    var values: [[String: Any?]] {
        return []
    }
    
}
