//
//  FormSectionHeaderView.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormSectionHeaderView: UIView {
    
    // MARK: Properties
    
    private var header: FormSectionHeaderType?
    
    
    // MARK: UI elements
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 10)
        return l
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        iv.widthAnchor.constraint(lessThanOrEqualTo: iv.heightAnchor, multiplier: 1.0).isActive = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(header: FormSectionHeaderType) {
        self.init(frame: .zero)
        
        self.header = header
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        setup()
        
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    
    // MARK: Setup
    
    fileprivate func setup() {
        guard let header = header else {
            return
        }
        
        addSubview(imageView)
        imageView.pin.edges([.leading, .top, .bottom]).to(self).activate()
        imageView.image = header.image
        
        addSubview(label)
        label.pin.leading.to(imageView.trailingAnchor).with(11).activate()
        label.pin.edges([.top, .trailing, .bottom]).to(self).activate()
        label.text = header.title
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
}
