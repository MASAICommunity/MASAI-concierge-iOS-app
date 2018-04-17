//
//  FormSectionHeader.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormSectionHeader: FormSectionHeaderType {
    
    // MARK: Properties
    
    let identifier: String
    let title: FormSectionHeaderType.SectionTitle
    let image: UIImage?
    
    
    // MARK: Lifecycle
    
    init(identifier: String, title: FormSectionHeaderType.SectionTitle, image: UIImage? = nil) {
        self.identifier = identifier
        self.title = title
        self.image = image
    }
    
    
    // MARK: View
    
    private var headerView: FormSectionHeaderView?
    
    func createView(forceRecreation: Bool) -> FormSectionHeaderView {
        if let hv = headerView,
            forceRecreation == false {
            return hv
        }
        
        headerView = FormSectionHeaderView(header: self)
        return headerView!
    }
    
}
