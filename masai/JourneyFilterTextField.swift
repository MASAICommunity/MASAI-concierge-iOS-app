//
//  JourneyFilterTextField.swift
//  masai
//
//  Created by Florian Rath on 28.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class JourneyFilterTextField: UITextField {
    
    // MARK: Properties
    
    let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0).cgColor
        layer.cornerRadius = 4.0
        font = UIFont.systemFont(ofSize: 13)
    }
    
    
    // MARK: Overrides
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func becomeFirstResponder() -> Bool {
//        backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
//        backgroundColor = .white
        
        return super.resignFirstResponder()
    }
}
