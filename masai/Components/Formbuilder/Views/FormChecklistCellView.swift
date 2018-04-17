//
//  FormChecklistCellView.swift
//  masai
//
//  Created by Florian Rath on 18.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class FormChecklistCellView: FormCellView {
    
    // MARK: Properties
    
    fileprivate var cell: FormCellType?
    fileprivate var selectionValues: [FormChecklistItemValue] = []
    
    
    // MARK: UI elements
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.heightAnchor.constraint(equalToConstant: 15).isActive = true
        l.font = UIFont.systemFont(ofSize: 8)
        l.textColor = UIColor(red: 147/255.0, green: 147/255.0, blue: 147/255.0, alpha: 1.0)
        return l
    }()
    
    fileprivate var checklistViews: [UIView] = []
    fileprivate var checklistAssociation: [UISwitch: FormChecklistItemValue] = [:]
    
    
    // MARK: Lifecycle
    
    convenience init(cell: FormCellType, selectionValues: [FormChecklistItemValue], validator: ValidatorType?) {
        self.init(frame: .zero)
        
        self.cell = cell
        self.selectionValues = selectionValues
        self.validator = validator
        
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
        label.pin.edges([.leading, .top, .trailing]).to(self).with(constants: [0, 4, 0]).activate()
        label.text = cell.title
        
        var topAnchoredView: UIView = label
        var lastCellView: UIView!
        for item in selectionValues {
            let view = createChecklistItemView(for: item)
            addSubview(view)
            
            view.pin.top.to(topAnchoredView.bottomAnchor).activate()
            view.pin.edges([.leading, .trailing]).to(self).activate()
            
            topAnchoredView = view
            lastCellView = view
        }
        lastCellView.pin.bottom.to(bottomAnchor).with(-8).activate()
    }
    
    private func createChecklistItemView(for item: FormChecklistItemValue) -> UIView {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(self.checkboxValueChanged(_:)), for: .valueChanged)
        sw.translatesAutoresizingMaskIntoConstraints = false
        checklistAssociation[sw] = item
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = item.title
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sw)
        contentView.addSubview(label)
        
        label.pin.edges([.top, .leading, .bottom]).to(contentView).with(constants: [2, 0, -2]).activate()
        sw.pin.leading.to(label.trailingAnchor).with(8).activate()
        sw.pin.edges([.top, .trailing, .bottom]).to(contentView).with(constants: [2, -2, -2]).activate()
        
        
        if let typedCell = cell as? FormChecklistCell,
            typedCell.selectedValues.filter({ $0.identifier == item.identifier }).count > 0 {
            sw.isOn = true
        }
        
        return contentView
    }
    
    
    // MARK: UI events
    
    @objc private func checkboxValueChanged(_ sender: UISwitch) {
        guard let item = checklistAssociation[sender] else {
            assert(false, "Received value changed event from checkbox which is not managed by us!")
            return
        }
        
        guard let cell = cell as? FormChecklistCell else {
            assert(false, "Associated cell with FormChecklistCellView is not a FormChecklistCell!")
            return
        }
        
        if sender.isOn {
            cell.selectedValues.append(item)
        } else {
            cell.selectedValues = cell.selectedValues.filter({ (arrayItem) -> Bool in
                return arrayItem != item
            })
        }
        
        NotificationCenter.default.post(name: FormNotifications.formValueChanged, object: nil, userInfo: ["form": (cell.form ?? nil) as Any])
    }
    
}
