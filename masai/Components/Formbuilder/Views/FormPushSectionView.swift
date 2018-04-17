//
//  FormPushSectionView.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormPushSectionView: UIView {
    
    // MARK: Properties
    
    private var section: FormSectionType?
    private var didTapClosure: FormPushSection.DidTapClosure?
    
    private weak var formView: UIView?
    
    
    // MARK: UI elements
    
    private let contentView: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.layer.cornerRadius = 4.0
        return cv
    }()
    
    private let toggleCollapseButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(section: FormSectionType, formView: UIView, didTapClosure: FormPushSection.DidTapClosure?) {
        self.init(frame: .zero)
        
        self.section = section
        self.formView = formView
        self.didTapClosure = didTapClosure
        
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
    
    
    // MARK: Public
    
    func setAlertHighlighted(_ shouldSet: Bool) {
        DispatchQueue.main.async {
            let borderColor = shouldSet ? UIColor(red: 239/255.0, green: 79/255.0, blue: 33/255.0, alpha: 1.0).cgColor : UIColor.clear.cgColor
            let borderWidth = CGFloat(shouldSet ? 1.0 : 0.0)
            self.contentView.layer.borderColor = borderColor
            self.contentView.layer.borderWidth = borderWidth
        }
    }
    
    
    // MARK: Setup
    
    fileprivate func setup() {
        guard let section = section else {
            return
        }
        
        addSubview(contentView)
        let insets = UIEdgeInsets(top: 8, left: 8, bottom: -8, right: -8)
        contentView.pinEdges(to: self, insets: insets).activate()
        
        let sectionHeader = section.header.createView()
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionHeader)
        sectionHeader.pin.edges([.leading, .top, .trailing, .bottom]).to(contentView).with(constants: [8, 0, -8, 0]).activate()
        
        let image = #imageLiteral(resourceName: "icon-arrow").withRenderingMode(.alwaysTemplate)
        toggleCollapseButton.setImage(image, for: .normal)
        toggleCollapseButton.tintColor = UIColor.dbRed
        toggleCollapseButton.isUserInteractionEnabled = false
        contentView.addSubview(toggleCollapseButton)
        toggleCollapseButton.pin.edges([.top, .trailing, .bottom]).to(sectionHeader).activate()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: UI events
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        if let closure = didTapClosure,
            let section = section as? FormPushSection {
            closure(section)
        }
    }
    
}
