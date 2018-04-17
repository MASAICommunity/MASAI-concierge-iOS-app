//
//  AutoLayoutHelper.swift
//
//  Created by Florian Rath on 25.12.16.
//  Copyright © 2016 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    
    static func constraintsForFilling(superview: UIView, with view: UIView) -> [NSLayoutConstraint] {
        
        return self.constraintsForFilling(superview: superview, with: view, insets: UIEdgeInsets.zero)
    }
    
    static func constraintsForFilling(superview: UIView, with view: UIView, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        
        return [
            view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: insets.right)
        ]
    }
	
	static func pinLeadingAndTrailing(of view: UIView, to otherView: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {
	    return [
	        view.leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: insets.left),
	        view.trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: insets.right)
	    ]
	}
}

extension Array where Element:NSLayoutConstraint {
    
    @discardableResult func activate() -> [Element] {
        
        for constraint in self {
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult func deactivate() -> [Element] {
        
        for constraint in self {
            constraint.isActive = false
        }
        return self
    }
}

enum AnchorSpecifier {
    case top
    case bottom
    case leading
    case trailing
}

class LayoutProxy {
    
    let view: UIView
    var anchors: [AnchorSpecifier] = []
    var constraints: [NSLayoutConstraint] = []
    
    init(view: UIView) {
        self.view = view
    }
    
    func edges(_ anchors: [AnchorSpecifier]) -> LayoutProxy {
        self.anchors.append(contentsOf: anchors)
        return self
    }
    
    var leading: LayoutProxy {
        self.anchors.append(.leading)
        return self
    }
    
    var trailing: LayoutProxy {
        self.anchors.append(.trailing)
        return self
    }
    
    var top: LayoutProxy {
        self.anchors.append(.top)
        return self
    }
    
    var bottom: LayoutProxy {
        self.anchors.append(.bottom)
        return self
    }
    
    func to(_ superview: UIView) -> LayoutProxy {
        for anchor in anchors {
            switch anchor {
            case .top:
                constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor))
            case .bottom:
                constraints.append(view.bottomAnchor.constraint(equalTo: superview.bottomAnchor))
            case .leading:
                constraints.append(view.leadingAnchor.constraint(equalTo: superview.leadingAnchor))
            case .trailing:
                constraints.append(view.trailingAnchor.constraint(equalTo: superview.trailingAnchor))
            }
        }
        return self
    }
    
    func to(_ superviewAnchor: NSLayoutYAxisAnchor) -> LayoutProxy {
        for anchor in anchors {
            switch anchor {
            case .top:
                constraints.append(view.topAnchor.constraint(equalTo: superviewAnchor))
            case .bottom:
                constraints.append(view.bottomAnchor.constraint(equalTo: superviewAnchor))
            default:
                fatalError("Cannot pin X to Y axis anchor.")
            }
        }
        return self
    }
    
    func to(_ superviewAnchor: NSLayoutXAxisAnchor) -> LayoutProxy {
        for anchor in anchors {
            switch anchor {
            case .leading:
                constraints.append(view.leadingAnchor.constraint(equalTo: superviewAnchor))
            case .trailing:
                constraints.append(view.trailingAnchor.constraint(equalTo: superviewAnchor))
            default:
                fatalError("Cannot pin X to Y axis anchor.")
            }
        }
        return self
    }
    
    func with(constants: [CGFloat]) -> LayoutProxy {
        assert(constraints.count == constants.count, "Constants must be specified for all registered constraints!")
        
        for (index, constraint) in constraints.enumerated() {
            constraint.constant = constants[index]
        }
        
        return self
    }
    
    func with(_ constant: CGFloat) -> LayoutProxy {
        for constraint in constraints {
            constraint.constant = constant
        }
        
        return self
    }
	
	func priority(_ priority: UILayoutPriority) -> LayoutProxy {
        for constraint in constraints {
            constraint.priority = priority
        }
       
        return self
    }
    
    func activate() {
        constraints.activate()
    }
    
}
