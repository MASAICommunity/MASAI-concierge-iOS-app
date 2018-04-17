//
//  FormSectionView.swift
//  masai
//
//  Created by Florian Rath on 11.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormSectionView: UIView {
    
    // MARK: Properties
    
    private var section: FormSectionType?
    
    private weak var formView: UIView?
    
    
    // MARK: UI elements
    
    private let contentView: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.layer.cornerRadius = 4.0
        return cv
    }()
    
    private let separatorView: UIView = {
        let sv = UIView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        sv.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        return sv
    }()
    
    private let formSectionContentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()
    
    private let toggleCollapseButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(section: FormSectionType, formView: UIView) {
        self.init(frame: .zero)
        
        self.section = section
        self.formView = formView
        
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
        guard let section = section else {
            return
        }
        
        addSubview(contentView)
        let insets = UIEdgeInsets(top: 8, left: 8, bottom: -8, right: -8)
        contentView.pinEdges(to: self, insets: insets).activate()
        
        let sectionHeader = section.header.createView()
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionHeader)
        sectionHeader.pin.edges([.leading, .top, .trailing]).to(contentView).with(constants: [8, 0, -8]).activate()
        
        contentView.addSubview(separatorView)
        separatorView.pin.top.to(sectionHeader.bottomAnchor).activate()
        separatorView.pin.edges([.leading, .trailing]).to(contentView).with(constants: [8, -8]).activate()
        
        contentView.addSubview(formSectionContentView)
        formSectionContentView.pin.top.to(separatorView.bottomAnchor).activate()
        formSectionContentView.pin.edges([.leading, .trailing]).to(contentView).with(constants: [8, -8]).activate()
        formSectionContentView.pin.bottom.to(contentView.bottomAnchor).activate()
        
        assert(section.cells.count > 0, "Cannot create a section without any cells in it!")
        
        var topAnchoredView: UIView? = nil
        var lastCellView: UIView!
        for cell in section.cells {
            let cellView = cell.createView()
            cellView.translatesAutoresizingMaskIntoConstraints = false
            formSectionContentView.addSubview(cellView)
            
            if let topAnchoredView = topAnchoredView {
                cellView.pin.top.to(topAnchoredView.bottomAnchor).activate()
            } else {
                cellView.pin.top.to(formSectionContentView).activate()
            }
            cellView.pin.edges([.leading, .trailing]).to(formSectionContentView).activate()
            topAnchoredView = cellView
            lastCellView = cellView
        }
        lastCellView.pin.bottom.to(formSectionContentView.bottomAnchor).with(-8).activate()
        
        let image = #imageLiteral(resourceName: "icon-arrow").withRenderingMode(.alwaysTemplate)
        toggleCollapseButton.setImage(image, for: .normal)
        toggleCollapseButton.tintColor = UIColor.dbRed
        toggleCollapseButton.isUserInteractionEnabled = false
        contentView.addSubview(toggleCollapseButton)
        toggleCollapseButton.pin.edges([.top, .trailing, .bottom]).to(sectionHeader).activate()
        toggleCollapseButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
    }
    
}
