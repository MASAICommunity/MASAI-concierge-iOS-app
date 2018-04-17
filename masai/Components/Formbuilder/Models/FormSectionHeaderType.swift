//
//  FormSectionHeaderType.swift
//  masai
//
//  Created by Florian Rath on 15.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


protocol FormSectionHeaderType {
    
    typealias SectionTitle = String
    
    var identifier: String { get }
    var title: SectionTitle { get }
    var image: UIImage? { get }
    
    func createView() -> FormSectionHeaderView
    func createView(forceRecreation: Bool) -> FormSectionHeaderView
}



extension FormSectionHeaderType {
    
    func createView() -> FormSectionHeaderView {
        return createView(forceRecreation: false)
    }
    
}
