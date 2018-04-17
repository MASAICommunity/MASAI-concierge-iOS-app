//
//  JourneySegmentTableViewCell.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit


class JourneySegmentTableViewCell: UITableViewCell {
    
    // MARK: Types
    
    enum TypeImage {
        case flight
        case car
        case hotel
        case train
        case activity
        
        var image: UIImage {
            switch self {
            case .flight:
                return #imageLiteral(resourceName: "icon-flights")
            case .car:
                return #imageLiteral(resourceName: "icon-rental-car")
            case .hotel:
                return #imageLiteral(resourceName: "icon-hotel")
            case .train:
                return #imageLiteral(resourceName: "icon-train")
            case .activity:
                return #imageLiteral(resourceName: "icon-activities")
            }
        }
    }
    
    enum SegmentPosition {
        case top
        case middle
        case bottom
        case none
    }
    
    
    // MARK: Properties
    
    internal class var identifier: String { return "JourneySegmentTableViewCell" }
    
    private let verticalPadding = CGFloat(2)
    private let horizontalPadding = CGFloat(4)
    
    var segmentPosition = SegmentPosition.none {
        didSet {
            let sectionImageWidth = CGFloat(24)
            switch segmentPosition {
            case .top:
                sectionGroupImageView.image = #imageLiteral(resourceName: "line-start")
                sectionGroupImageViewWidthConstraint.constant = sectionImageWidth
                
            case .middle:
                sectionGroupImageView.image = #imageLiteral(resourceName: "line-mid")
                sectionGroupImageViewWidthConstraint.constant = sectionImageWidth
                
            case .bottom:
                sectionGroupImageView.image = #imageLiteral(resourceName: "line-end")
                sectionGroupImageViewWidthConstraint.constant = sectionImageWidth
                
            case .none:
                sectionGroupImageView.image = nil
                sectionGroupImageViewWidthConstraint.constant = 0
            }
        }
    }
    
    static let defaultBorderColor = UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
    static let highlightedBorderColor = UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 1.0)
    
    
    // MARK: UI
    
    internal var borderedContentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.borderColor = JourneySegmentTableViewCell.defaultBorderColor.cgColor
        v.layer.borderWidth = 2.0
        v.layer.cornerRadius = 4.0
        return v
    }()
    
    internal var sectionGroupImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    internal var sectionGroupImageViewWidthConstraint: NSLayoutConstraint!
    
    internal var segmentTypeImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    internal var verticalSeparatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.clear
        v.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        return v
    }()
    
    internal var dataContentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    internal var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    internal var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 87/255.0, green: 87/255.0, blue: 87/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: 11)
        return l
    }()
    
    internal var dateIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "icon-ticket-date")
        return iv
    }()
    internal var dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 87/255.0, green: 87/255.0, blue: 87/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: 9, weight: UIFontWeightThin)
        return l
    }()
    
    internal var timeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "icon-ticket-time")
        return iv
    }()
    internal var timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 87/255.0, green: 87/255.0, blue: 87/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: 9, weight: UIFontWeightThin)
        return l
    }()
    
    internal var separatorBorderLayer: CAShapeLayer!
    internal let separatorBorderLayerEdge = UIRectEdge.left
    internal let separatorBorderLayerColor = UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
    internal let separatorBorderWidth = CGFloat(1.0)
    internal let separatorBorderDashPattern: [NSNumber] = [5, 5]
    
    
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        let imageViewPadding = CGFloat(16)
        
        contentView.addSubview(sectionGroupImageView)
        sectionGroupImageView.pin.edges([.leading, .top, .bottom]).to(contentView).with(constants: [horizontalPadding, 0, 0]).activate()
        sectionGroupImageViewWidthConstraint = sectionGroupImageView.widthAnchor.constraint(equalToConstant: 0)
        sectionGroupImageViewWidthConstraint.isActive = true
        
        contentView.addSubview(borderedContentView)
        borderedContentView.pin.edges([.top, .trailing, .bottom]).to(contentView).with(constants: [verticalPadding, -horizontalPadding, -verticalPadding]).activate()
        borderedContentView.pin.leading.to(sectionGroupImageView.trailingAnchor).activate()
        
        // Bordered content view
        borderedContentView.addSubview(segmentTypeImageView)
        segmentTypeImageView.pin.edges([.leading, .top, .bottom]).to(borderedContentView).with(constants: [imageViewPadding, imageViewPadding, -imageViewPadding]).activate()
        segmentTypeImageView.widthAnchor.constraint(equalTo: segmentTypeImageView.heightAnchor, multiplier: 1.0).isActive = true
        
        borderedContentView.addSubview(verticalSeparatorView)
        verticalSeparatorView.pin.edges([.top, .bottom]).to(borderedContentView).activate()
        verticalSeparatorView.pin.leading.to(segmentTypeImageView.trailingAnchor).with(imageViewPadding).activate()
        
        separatorBorderLayer = CALayer.createDashedBorderLayer(edge: separatorBorderLayerEdge, color: separatorBorderLayerColor, thickness: separatorBorderWidth, dashPattern: separatorBorderDashPattern)
        verticalSeparatorView.layer.addSublayer(separatorBorderLayer)
        
        borderedContentView.addSubview(dataContentView)
        dataContentView.pin.edges([.top, .bottom]).to(borderedContentView).with(constants: [12, -12]).activate()
        dataContentView.pin.leading.to(verticalSeparatorView.trailingAnchor).with(imageViewPadding).activate()
        
        borderedContentView.addSubview(logoImageView)
        logoImageView.pin.edges([.top, .bottom, .trailing]).to(borderedContentView).with(constants: [imageViewPadding, -imageViewPadding, -imageViewPadding]).activate()
//        logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 1.0).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 0).isActive = true
        logoImageView.pin.leading.to(dataContentView.trailingAnchor).with(8).activate()
        
        // Data view
        let dataViewLabelMargin = CGFloat(2)
        
        dataContentView.addSubview(titleLabel)
        dataContentView.addSubview(dateIconImageView)
        dataContentView.addSubview(dateLabel)
        dataContentView.addSubview(timeIconImageView)
        dataContentView.addSubview(timeLabel)
        
        titleLabel.pin.edges([.leading, .top, .trailing]).to(dataContentView).activate()
        
        dateIconImageView.pin.leading.to(dataContentView).activate()
        dateIconImageView.heightAnchor.constraint(equalTo: dateIconImageView.widthAnchor, multiplier: 1.0).isActive = true
        dateIconImageView.pin.edges([.top, .bottom]).to(dateLabel).activate()
        
        dateLabel.pin.leading.to(dateIconImageView.trailingAnchor).with(4).activate()
        dateLabel.pin.trailing.to(dataContentView).activate()
        dateLabel.pin.top.to(titleLabel.bottomAnchor).with(dataViewLabelMargin).activate()
        
        timeIconImageView.pin.leading.to(dataContentView).activate()
        timeIconImageView.heightAnchor.constraint(equalTo: timeIconImageView.widthAnchor, multiplier: 1.0).isActive = true
        timeIconImageView.pin.edges([.top, .bottom]).to(timeLabel).activate()
        
        timeLabel.pin.leading.to(timeIconImageView.trailingAnchor).with(4).activate()
        timeLabel.pin.edges([.trailing, .bottom]).to(dataContentView).activate()
        timeLabel.pin.top.to(dateLabel.bottomAnchor).with(dataViewLabelMargin).activate()
        
        titleLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, multiplier: 1.0).isActive = true
        dateLabel.heightAnchor.constraint(equalTo: timeLabel.heightAnchor, multiplier: 1.0).isActive = true
    }
    
    internal func fillDateTime(from dateTimeString: String?) {
        dateLabel.text = ""
        timeLabel.text = ""
        if let tuple = dateTimeFrom(backendDateString: dateTimeString) {
            dateLabel.text = tuple.0
            timeLabel.text = tuple.1
        }
    }
    
    func setup(with segment: Segment) {
    }
    
    
    // MARK: UI events
    
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            self.verticalSeparatorView.layer.updateFrame(for: self.separatorBorderLayer, edge: self.separatorBorderLayerEdge, thickness: self.separatorBorderWidth)
        }
    }
    
    
    // MARK: Highlighting
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let highlightClosure = { [unowned self] in
            if highlighted {
                self.borderedContentView.layer.borderColor = JourneySegmentTableViewCell.highlightedBorderColor.cgColor
                self.borderedContentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 240/255.0)
            } else {
                self.borderedContentView.layer.borderColor = JourneySegmentTableViewCell.defaultBorderColor.cgColor
                self.borderedContentView.backgroundColor = UIColor.white
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                highlightClosure()
            })
        } else {
            highlightClosure()
        }
    }
    
    
    // MARK: Private
    
    internal func dateTimeFrom(backendDateString dateString: String?) -> (String, String)? {
        return SegmentFactory.dateTimeFrom(backendDateString: dateString)
    }
    
    internal func dateFromBackend(dateString: String) -> Date? {
        return SegmentFactory.dateFromBackend(dateString: dateString)
    }
    
}
