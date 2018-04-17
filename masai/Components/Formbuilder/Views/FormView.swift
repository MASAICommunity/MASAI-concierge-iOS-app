//
//  FormView.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormView: UIView {
    
    // MARK: Properties
    
    private var form: FormType?
    
    
    // MARK: UI elements
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .clear
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    private let contentView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        return sv
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(form: FormType) {
        self.init(frame: .zero)
        
        self.form = form
        
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
        guard let form = form else {
            return
        }
        
        addSubview(scrollView)
        scrollView.pinEdges(to: self).activate()
        
        scrollView.addSubview(contentView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.pinEdges(to: scrollView).activate()
        
        for section in form.sections.reversed() {
            let sectionView = section.createView(formView: self)
            sectionView.translatesAutoresizingMaskIntoConstraints = false
            contentView.insertArrangedSubview(sectionView, at: 0)
            NSLayoutConstraint.pinLeadingAndTrailing(of: sectionView, to: contentView).activate()
        }
    }
    
}
