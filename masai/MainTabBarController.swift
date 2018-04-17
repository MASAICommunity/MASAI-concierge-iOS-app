//
//  MainTabBarController.swift
//  masai
//
//  Created by Florian Rath on 19.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class MainTabBarController: UITabBarController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        updateTitles()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        if let navController = navigationController as? BaseNavigationController {
            navController.hideStatusBarBackgroundView = true
        }
        
        self.delegate = self
        
        _ = Constants.Notification.openChatPushRequest.observe { (note: Notification) in
            guard let userInfo = note.userInfo,
                let request = userInfo["request"] as? PushOpenChatRequest else {
                    return
            }
            
            DispatchQueue.main.async {
                // Open Conversation list
                guard let conversationNavC = self.viewControllers?.first as? BaseNavigationController,
                    let conversationVC = conversationNavC.viewControllers.first as? ConversationListViewController else {
                    return
                }
                
                // Check if we already have the correct chat channel open
                let roomIdOfOpenChat = (conversationNavC.topViewController as? ChatViewController)?.channel.roomId
                let isCorrectChatAlreadyOpen = (roomIdOfOpenChat == request.roomId)
                if !isCorrectChatAlreadyOpen {
                    // Queue push request
                    conversationVC.pushRequest = request
                    
                    // Close potential host-selection-vc popup
                    if let presentedVC = conversationNavC.presentedViewController as? BaseNavigationController,
                        let selectHostVC = presentedVC.viewControllers.first as? SelectHostViewController {
                        selectHostVC.dismiss(animated: false, completion: nil)
                    }
                    
                    // Pop to root vc (= conversation list vc) if needed
                    if conversationNavC.topViewController != conversationVC {
                        conversationNavC.popToRootViewController(animated: false)
                    } else {
                        conversationVC.reloadChannels()
                    }
                }
                
                // Change tab to concierge tab
                self.selectedIndex = 0
            }
        }
    }
    
    
    // MARK: Public
    
    func openProfile() {
        selectedIndex = (viewControllers?.count ?? 1) - 1
    }
    
    
    // MARK: Private
    
    private func updateTitles() {
        for vc in (viewControllers ?? []) {
            vc.view.layoutIfNeeded()
        }
    }
    
    fileprivate func retrieveViewControllers(_ viewController: UIViewController) -> (from: UIViewController, to: UIViewController)? {
        guard let fromNavC = selectedViewController as? BaseNavigationController,
            let toNavC = viewController as? BaseNavigationController,
            let fromVC = fromNavC.childViewControllers.first,
            let toVC = toNavC.childViewControllers.first else {
                return nil
        }
        
        return (fromVC, toVC)
    }
    
    fileprivate func isNavigationFrom(profile from: UIViewController, to viewController: UIViewController) -> Bool {
        if let fromVC = from as? ProfileViewController,
            fromVC != viewController {
            return true
        }
        
        return false
    }
    
    fileprivate func isNavigationFrom(other from: UIViewController, toHistory to: UIViewController) -> Bool {
        if let to = to as? HistoryViewController,
            from != to {
            return true
        }
        
        return false
    }
    
}


// MARK: UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = retrieveViewControllers(viewController) {
            if isNavigationFrom(profile: viewControllers.from, to: viewControllers.to) {
                let userProfile = CacheManager.retrieveUserProfile()
                userProfile?.postToBackendIfNeeded()
            }
            
            if isNavigationFrom(other: viewControllers.from, toHistory: viewControllers.to),
                let historyVC = viewControllers.to as? HistoryViewController {
                historyVC.reloadHistory()
            }
        }
        
        return true
    }
    
}
