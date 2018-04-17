//
//  FormLabelCellView.swift
//  masai
//
//  Created by Thomas Svitil on 06.09.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

class FormLabelCellView: FormCellView {
    
    // MARK: Properties
    
    fileprivate var cell: FormCellType?
    
    
    // MARK: UI elements
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .black
        l.numberOfLines = 0
        return l
    }()
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType) {
        self.init(frame: .zero)
        
        self.cell = cell;
        
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
    
    private func setup() {
        guard let cell = cell else {
            return
        }
        
        addSubview(label)
        label.pin.edges([.leading, .top, .trailing, .bottom]).to(self).with(constants: [0, 8, 0, 0]).activate()
        label.text = cell.title
    }
}
