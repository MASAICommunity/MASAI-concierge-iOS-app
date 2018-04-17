//
//  UIView+AutoLayoutExtensions.swift
//  calendar
//
//  Created by Florian Rath on 08.06.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    convenience init(autoLayout: Bool = true) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = !(autoLayout)
    }
    
    func pinEdges(to superview: UIView, insets: UIEdgeInsets? = nil) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsForFilling(superview: superview, with: self, insets: (insets ?? UIEdgeInsets.zero))
    }
	
    func pinCenter(to view: UIView) -> [NSLayoutConstraint] {
        return [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }
    
    var pin: LayoutProxy {
        return LayoutProxy(view: self)
    }
    
}
