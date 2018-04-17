//
//  ProfileSwitchButtonView.swift
//  masai
//
//  Created by Florian Rath on 19.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileSwitchButtonView: UIView {
    
    typealias TransitionToButtonAnimationClosure = ((_ selectedIndex: Int, _ selectedTitle: String)->Void)
    
    // MARK: Properties
    
    private var titles: [String] = []
    private var images: [UIImage] = []
    
    var transitionToButtonAnimationClosure: TransitionToButtonAnimationClosure?
    
    private var selectionViewConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: UI elements
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 0
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let selectionView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 99/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1.0)
        return v
    }()
    
    private var buttons: [UIButton] = []
    
    
    // MARK: Lifecycle
    
    convenience init(titles: [String], images: [UIImage]) {
        self.init(frame: .zero)
        self.titles = titles
        self.images = images
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
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
        guard titles.count > 0 else {
            return
        }
        
        clipsToBounds = true
        
        backgroundColor = UIColor(red: 72/255.0, green: 72/255.0, blue: 72/255.0, alpha: 1.0)
        
        addSubview(selectionView)
        
        addSubview(stackView)
        stackView.pinEdges(to: self).activate()
        
        assert(titles.count == images.count, "Every set title must have a corresponding image")
        
        for (index, title) in titles.enumerated() {
            let image = images[index].withRenderingMode(.alwaysTemplate)
            
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 8.0)
            label.textAlignment = .center
            
            let buttonView = UIView()
            buttonView.translatesAutoresizingMaskIntoConstraints = false
            buttonView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            buttonView.backgroundColor = .clear
            buttonView.clipsToBounds = true
            
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index
            button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
            buttons.append(button)
            
            buttonView.addSubview(imageView)
            buttonView.addSubview(label)
            buttonView.addSubview(button)
            label.pin.edges([.leading, .trailing, .bottom]).to(buttonView).with(constants: [10, -10, -10]).activate()
            imageView.pin.edges([.leading, .trailing, .top]).to(buttonView).with(constants: [10, -10, 10]).activate()
            NSLayoutConstraint.constraintsForFilling(superview: buttonView, with: button, insets: UIEdgeInsets(top: -1, left: -1, bottom: 1, right: 0)).activate()
            
            stackView.addArrangedSubview(buttonView)
            
            // Add right border to button
            button.layer.borderColor = UIColor(red: 61/255.0, green: 61/255.0, blue: 61/255.0, alpha: 1.0).cgColor
            button.layer.borderWidth = 1.0
        }
        
        // Clear the right border of the last button
        buttons.last!.layer.borderColor = UIColor.clear.cgColor
        
        selectionViewConstraints = NSLayoutConstraint.constraintsForFilling(superview: selectionView, with: buttons.first!)
        selectionViewConstraints.activate()
    }
    
    
    // MARK: UI events
    
    @objc private func buttonPressed(_ sender: UIButton) {
        let index = sender.tag
        let title = titles[index]
        let button = buttons[index]
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.transitionToButtonAnimationClosure?(index, title)
            
            self.selectionViewConstraints.deactivate()
            self.selectionViewConstraints = NSLayoutConstraint.constraintsForFilling(superview: self.selectionView, with: button)
            self.selectionViewConstraints.activate()
            self.layoutIfNeeded()
        }
        
    }
    
}
