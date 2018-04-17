//
//  ProfileTextField.swift
//  masai
//
//  Created by Florian Rath on 14.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileTextField: UITextField {
    
    // MARK: Properties
    
    struct Icons {
        static let defaultImage: UIImage = {
            return #imageLiteral(resourceName: "icon-edit")
        }()
        static let editingImage: UIImage = {
            return #imageLiteral(resourceName: "icon-editing")
        }()
        static let doneImage: UIImage = {
            return #imageLiteral(resourceName: "icon-edit-done")
        }()
        static let validationFailedImage: UIImage = {
            return #imageLiteral(resourceName: "icon-warning")
        }()
        static let noImage: UIImage? = nil
    }
    
    static let iconSize = CGFloat(20)
    
    let padding = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14 + ProfileTextField.iconSize)
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
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
        heightAnchor.constraint(equalToConstant: 42).isActive = true
        textColor = UIColor(red: 56/255.0, green: 56/255.0, blue: 56/255.0, alpha: 1.0)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0).cgColor
        layer.cornerRadius = 4.0
        font = UIFont.systemFont(ofSize: 13)
        
        addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: ProfileTextField.iconSize).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11).isActive = true
        imageView.image = Icons.defaultImage
    }
    
    
    // MARK: Overrides
    
    override func setValid() {
        layer.borderColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0).cgColor
        imageView.image = Icons.defaultImage
    }
    
    override func setInvalid() {
        layer.borderColor = UIColor(red: 239/255.0, green: 79/255.0, blue: 33/255.0, alpha: 1.0).cgColor
        imageView.image = Icons.validationFailedImage
    }
    
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
        backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        imageView.image = Icons.editingImage
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        backgroundColor = .white
        imageView.image = Icons.defaultImage
        
        return super.resignFirstResponder()
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = UIColor.white
                imageView.image = Icons.defaultImage
            } else {
                backgroundColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
                imageView.image = Icons.noImage
            }
        }
    }
}
