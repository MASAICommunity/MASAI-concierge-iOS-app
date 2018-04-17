//
//  BaseNavigationController.swift
//  masai
//
//  Created by Florian Rath on 19.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class BaseNavigationController: UINavigationController {
    
    // MARK: Properties
    
    var hideStatusBarBackgroundView: Bool = false {
        didSet {
            statusBarBackgroundView?.isHidden = hideStatusBarBackgroundView
        }
    }
    
    
    // MARK: UI
    
    private var statusBarBackgroundView: UIView?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationBar.shadowImage = UIImage()
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.dbRed
        var existingAttributes = navigationController?.navigationBar.titleTextAttributes ?? [:]
        existingAttributes[NSForegroundColorAttributeName] = UIColor.white
        navigationBar.titleTextAttributes = existingAttributes
        
        for item in (navigationItem.rightBarButtonItems ?? []) {
            item.tintColor = UIColor.white
        }
        for item in (navigationItem.leftBarButtonItems ?? []) {
            item.tintColor = UIColor.white
        }
        
        statusBarBackgroundView = UIView()
        statusBarBackgroundView!.translatesAutoresizingMaskIntoConstraints = false
        statusBarBackgroundView!.backgroundColor = UIColor(red: 63/255.0, green: 65/255.0, blue: 68/255.0, alpha: 1.0)
        view.addSubview(statusBarBackgroundView!)
        statusBarBackgroundView!.pin.edges([.leading, .top, .trailing]).to(view).activate()
        statusBarBackgroundView!.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.size.height).isActive = true
    }
    
    
    // MARK: Status Bar Style
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
}
