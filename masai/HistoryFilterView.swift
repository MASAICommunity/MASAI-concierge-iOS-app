//
//  HistoryFilterView.swift
//  masai
//
//  Created by Florian Rath on 23.11.17.
//  Copyright © 2017 5lvlup gmbh. All rights reserved.
//

import Foundation
import UIKit


class HistoryFilterView: UIView {
    
    // MARK: Types
    
    enum SearchScope: Int {
        case text = 0
        case date = 1
    }
    
    typealias TextSearchedClosure = (_ searchTerm: String?) -> Void
    typealias DateSearchedClosure = (_ searchedDate: Date?) -> Void
    
    
    // MARK: Properties
    
    var textSearchedClosure: TextSearchedClosure?
    var dateSearchedClosure: DateSearchedClosure?
    
    private(set) var scope = SearchScope.text {
        didSet {
            let wasFirstResponder = filterTextfield.isFirstResponder
            
            filterTextfield.text = nil
            
            switch scope {
            case .text:
                filterTextfield.inputView = nil
            case .date:
                filterTextfield.inputView = datePicker
            }
            
            updateUIForState()
            
            if wasFirstResponder {
                if scope == .date {
                    filterTextfield.text = dateFormatter.string(from: Date())
                }
                _ = filterTextfield.becomeFirstResponder()
            }
        }
    }
    
    var searchTerm: String? {
        switch scope {
        case .text:
            return filterTextfield.text
        case .date:
            return nil
        }
    }
    
    var searchDate: Date? {
        switch scope {
        case .text:
            return nil
        case .date:
            guard let text = filterTextfield.text else {
                return nil
            }
            return dateFormatter.date(from: text)
        }
    }
    
    fileprivate var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    
    // MARK: UI
    
    private var filterLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "history_filter_textlabel".localized
        l.textAlignment = .center
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 12)
        return l
    }()
    
    private var filterSegmentedView: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            "history_filter_text".localized,
            "history_filter_date".localized
            ])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    fileprivate var filterTextfield: JourneyFilterTextField = {
        let tf = JourneyFilterTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "journey_filter_textfield_placeholder".localized //history_filter_textfield_date_placeholder
        tf.backgroundColor = .white
        tf.clearButtonMode = .always
        tf.tintColor = UIColor.dbRed
        return tf
    }()
    
    private var filterSearchButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("journey_filter_search_button".localized, for: .normal)
        
        b.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        b.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        b.backgroundColor = UIColor.dbRed
        b.layer.cornerRadius = 4.0
        b.setTitleColor(UIColor.dbRed, for: .normal)
        b.backgroundColor = UIColor.white
        return b
    }()
    
    private var outOfBoundsBackgroundColorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.dbRed
        return v
    }()
    
    fileprivate var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        return dp
    }()
    
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        backgroundColor = UIColor.dbRed
        clipsToBounds = false
        
        // Layout
        
        addSubview(filterLabel)
        addSubview(filterSegmentedView)
        addSubview(filterTextfield)
        addSubview(filterSearchButton)
        addSubview(outOfBoundsBackgroundColorView)
        
        filterLabel.pin.edges([.leading, .top, .trailing]).to(self).with(constants: [8, 8, -8]).activate()
        
        filterSegmentedView.pin.top.to(filterLabel.bottomAnchor).with(8).activate()
        filterSegmentedView.pin.edges([.leading, .trailing]).to(filterLabel).activate()
        
        filterTextfield.pin.top.to(filterSegmentedView.bottomAnchor).with(8).activate()
        filterTextfield.pin.edges([.leading, .trailing]).to(filterLabel).activate()
        
        filterSearchButton.pin.top.to(filterTextfield.bottomAnchor).with(8).activate()
        filterSearchButton.pin.trailing.to(filterLabel).activate()
        filterSearchButton.pin.bottom.to(self).with(-8).activate()
        
        outOfBoundsBackgroundColorView.pin.edges([.leading, .trailing]).to(self).activate()
        outOfBoundsBackgroundColorView.pin.bottom.to(self.topAnchor).activate()
        outOfBoundsBackgroundColorView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height).isActive = true
        
        // Logic
        
        filterSegmentedView.addTarget(self, action: #selector(self.segmentedViewValueChanged(_:)), for: .valueChanged)
        
        filterTextfield.delegate = self
        
        filterSearchButton.addTarget(self, action: #selector(self.searchButtonPressed(_:)), for: .touchUpInside)
        
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: .valueChanged)
    }
    
    
    // MARK: UI events
    
    @objc private func segmentedViewValueChanged(_ sender: UISegmentedControl) {
        scope = SearchScope(rawValue: sender.selectedSegmentIndex)!
    }
    
    @objc fileprivate func searchButtonPressed(_ sender: UIButton?) {
        _ = filterTextfield.resignFirstResponder()
        
        switch scope {
        case .text:
            textSearchedClosure?(searchTerm)
        case .date:
            dateSearchedClosure?(searchDate)
        }
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        filterTextfield.text = dateFormatter.string(from: sender.date)
    }
    
    
    // MARK: Public
    
    func clearFilters() {
        filterTextfield.text = nil
        filterSegmentedView.selectedSegmentIndex = 0
        scope = .text
        
    }
    
    
    // MARK: Private
    
    private func updateUIForState() {
        switch scope {
        case .text:
            filterTextfield.placeholder = "journey_filter_textfield_placeholder".localized
        case .date:
            filterTextfield.placeholder = "history_filter_textfield_date_placeholder".localized
        }
    }
    
}


// MARK: UITextFieldDelegate
extension HistoryFilterView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == filterTextfield,
            scope == .date {
            
            if let text = filterTextfield.text,
                let textFieldDate = dateFormatter.date(from: text) {
                datePicker.date = textFieldDate
            } else {
                datePicker.date = Date()
                filterTextfield.text = dateFormatter.string(from: Date())
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == filterTextfield {
            searchButtonPressed(nil)
        }
        
        return true
    }
    
}
