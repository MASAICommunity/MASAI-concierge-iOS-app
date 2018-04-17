//
//  BaseViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

protocol NavigationBarInterface {
    func isNavigationBarVisible() -> Bool
    func isNavigationBarRightItemVisible() -> Bool
    func isNavigationBarLeftItemVisible() -> Bool
    func isNavigationBarBackButtonVisible() -> Bool

    func titleForNavigationBar() -> String?
    func titleForNavigationBarRightItem() -> String?
    func titleForNavigationBarLeftItem() -> String?
    func titleForNavigationBarBackButton() -> String?
    func imageForNavigationBarLeftItem() -> UIImage?
    func imageForNavigationBarRightItem() -> UIImage?
    
    func onPressedNavigationBarRightButton()
    func onPressedNavigationBarLeftButton()
}


class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func className() -> String? {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last
    }
    
    func updateNavigationBar() {
        if isNavigationBarVisible() {
            self.navigationController?.navigationBar.isHidden = false
            updateNavigationBarTitle()
            updateNavigationBarBackButton()
            updateNavigationBarLeftItem()
            updateNavigationBarRightItem()
        } else {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    func updateNavigationBarTitle() {
        title = titleForNavigationBar()
    }
    
    func updateNavigationBarRightItem() {
        if isNavigationBarRightItemVisible() {
            if let image = imageForNavigationBarRightItem() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onPressedNavigationBarRightButton))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: titleForNavigationBarRightItem(), style: .plain,
                                                                         target:self, action: #selector(onPressedNavigationBarRightButton))
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        for item in (navigationItem.rightBarButtonItems ?? []) {
            item.tintColor = UIColor.white
        }
    }
    
    func updateNavigationBarLeftItem() {
        if isNavigationBarLeftItemVisible() {
            if let image = imageForNavigationBarLeftItem() {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(onPressedNavigationBarLeftButton))
            } else {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: titleForNavigationBarLeftItem(), style: .plain, target:self, action: #selector(onPressedNavigationBarLeftButton))
            }
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        for item in (navigationItem.leftBarButtonItems ?? []) {
            item.tintColor = UIColor.white
        }
    }
    
    func updateNavigationBarBackButton() {
        self.navigationItem.hidesBackButton = !isNavigationBarBackButtonVisible()
        if isNavigationBarBackButtonVisible() {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: titleForNavigationBarBackButton(), style: .plain, target: nil, action: nil)
        } else {
            self.navigationItem.backBarButtonItem = nil
        }
        
        if let backButton = self.navigationItem.backBarButtonItem {
            backButton.tintColor = UIColor.white
        }
    }
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

extension BaseViewController: NavigationBarInterface {
    
    func isNavigationBarVisible() -> Bool {
        return true
    }
    
    func isNavigationBarRightItemVisible() -> Bool {
        return false
    }
    
    func isNavigationBarBackButtonVisible() -> Bool {
        return true
    }
    
    func isNavigationBarLeftItemVisible() -> Bool {
        return false
    }
    
    func titleForNavigationBar() -> String? {
        return nil
    }
    
    func titleForNavigationBarRightItem() -> String? {
        let logError = "Function titileForNavigationBarRightItem must be overridden in \(String(describing: className())) if right navigation item is visible!"
        assert(!isNavigationBarRightItemVisible(), logError)
        return nil
    }
    
    func titleForNavigationBarLeftItem() -> String? {
        let logError = "Function titleForNavigationBarLeftItem must be overridden in \(String(describing: className())) if left navigation item is visible!"
        assert(!isNavigationBarLeftItemVisible(), logError)
        return nil
    }
    
    func titleForNavigationBarBackButton() -> String? {
        return "Back".localized
    }
    
    func onPressedNavigationBarRightButton() {
        let logError = "Function onPressedNavigationBarRightButton must be overridden in \(String(describing: className())) if right navigation item is visible!"
        assert(!isNavigationBarRightItemVisible(), logError)
    }
    
    func onPressedNavigationBarLeftButton() {
        let logError = "Function onPressedNavigationBarLeftButton must be overridden in \(String(describing: className())) if left navigation item is visible!"
        assert(!isNavigationBarLeftItemVisible(), logError)
    }
    
    func isNavigationBarLeftItemCustomView() -> Bool {
        return false
    }
    
    func imageForNavigationBarLeftItem() -> UIImage? {
        let logError = "Function imageForNavigationBarLeftItem must be overridden in \(String(describing: className())) if left navigation item is image!"
        assert(!isNavigationBarLeftItemCustomView(), logError)
        return nil
    }
    
    func imageForNavigationBarRightItem() -> UIImage? {
        let logError = "Function imageForNavigationBarLeftItem must be overridden in \(String(describing: className())) if left navigation item is image!"
        assert(!isNavigationBarLeftItemCustomView(), logError)
        return nil
    }
}
