//
//  LoadingIndicator.swift
//  masai
//
//  Created by Florian Rath on 07.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class LoadingIndicator {
    
    // MARK: Types
    
    typealias BeforeStartClosure = () -> Void
    typealias AfterStopClosure = () -> Void
    
    
    // MARK: Properties
    
    private var indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        v.color = UIColor.orangeMasai
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
    }()
    
    private var beforeStartClosure: BeforeStartClosure?
    private var afterStopClosure: AfterStopClosure?
    
    
    // MARK: Setup
    
    func setup(in view: UIView) {
        view.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setBehaviourBeforeStart(_ closure: @escaping BeforeStartClosure) {
        beforeStartClosure = closure
    }
    
    func setBehaviourAfterStop(_ closure: @escaping AfterStopClosure) {
        afterStopClosure = closure
    }
    
    
    // MARK: Public
    
    func startAnimating() {
        DispatchQueue.main.async { [unowned self] in
            if let c = self.beforeStartClosure {
                c()
            }
            
            self.indicator.startAnimating()
        }
    }
    
    func stopAnimating() {
        DispatchQueue.main.async { [unowned self] in
            self.indicator.stopAnimating()
            
            if let c = self.afterStopClosure {
                c()
            }
        }
    }
    
}
