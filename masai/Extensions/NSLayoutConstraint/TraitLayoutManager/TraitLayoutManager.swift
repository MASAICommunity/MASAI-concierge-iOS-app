//
//  TraitLayoutManager.swift
//  calendar
//
//  Created by Florian Rath on 07.06.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

class TraitLayoutManager: NSObject {
    
    // MARK: Properties
    
    weak var rootView: UIView?
    var proxyView: TraitProxyView?
    private var registeredConstraints: [TraitOptions: [NSLayoutConstraint]] = [:]
    
    
    // MARK: Lifecycle
    
    init(rootView: UIView) {
        self.rootView = rootView
        
        super.init()
        
        setupProxyView()
    }
    
    
    // MARK: Public
    
    func register(constraints: [NSLayoutConstraint], for options: TraitOptions) {
        var existingOptions = registeredConstraints[options] ?? []
        existingOptions.append(contentsOf: constraints)
        registeredConstraints[options] = existingOptions
    }
    
    
    // MARK: Private
    
    private func setupProxyView() {
        proxyView = TraitProxyView()
        proxyView?.traitCollectionDidChangeClosure = { [weak self] (current, previous) in
            self?.traitCollectionDidChange(to: current, from: previous)
        }
        
        rootView?.addSubview(proxyView!)
    }
    
    private func traitCollectionDidChange(to current: UITraitCollection, from previous: UITraitCollection?) {
        if previous?.horizontalSizeClass != current.horizontalSizeClass ||
            previous?.verticalSizeClass != current.verticalSizeClass {
//            print("trait collection did change!")
//            print("from \(previous?.horizontalSizeClass.rawValue) to \(current.horizontalSizeClass.rawValue)")
            activateRegisteredConstraints(for: TraitOptions.from(traits: current))
        }
    }
    
    private func activateRegisteredConstraints(for traits: TraitOptions) {
        let activatingConstraints = registeredConstraints
            .filter({ (registration) -> Bool in
                return registration.key.matches(options: traits)
            })
            .flatMap { (registration) -> [NSLayoutConstraint] in
                return registration.value
        }
        let deactivatingConstraints = registeredConstraints
            .flatMap({ (registration) -> [NSLayoutConstraint] in
                return registration.value
            })
            .filter { (constraint) -> Bool in
                return !activatingConstraints.contains(constraint)
        }
        
        for constraint in deactivatingConstraints {
            constraint.isActive = false
        }
        
        for constraint in activatingConstraints {
            constraint.isActive = true
        }
    }
    
}
