//
//  NSAutolayoutConstraint+Priority.swift
//
//  Created by Florian Rath on 26.04.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit


extension NSLayoutConstraint {
    
    func with(priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
    
}
