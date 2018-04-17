//
//  AppDelegate.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Auth0
import IQKeyboardManagerSwift
import AlamofireNetworkActivityIndicator


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var isFreshLaunch = false
    
    var pushNotificationHandler = PushNotifications()

    var window: UIWindow?

    
    // MARK: Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isFreshLaunch = true
        
        Fabric.with([Crashlytics.self])
        
        // Start network reachability scanning
        _ = ReachabilityManager.shared
        
        // Begin listening for history changes
        _ = HistoryManager.shared

//        let textAttributes = [NSForegroundColorAttributeName:UIColor.greyMasai]
//        UINavigationBar.appearance().titleTextAttributes = textAttributes
//        UINavigationBar.appearance().tintColor = UIColor.greyMasai
//        UINavigationBar.appearance().backgroundColor = UIColor.navigationWhite
        
        UITabBar.appearance().backgroundColor = UIColor(red: 254/255, green: 254/255, blue: 254/255, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor.orangeMasai
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        IQKeyboardManager.sharedManager().enable = true
        
        // Configure Alamofire network indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // Setup push handler
        pushNotificationHandler.setup()
        
        // Register for remote notifications
        PushNotifications.registerForPushNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        let userProfile = CacheManager.retrieveUserProfile()
        userProfile?.postToBackendIfNeeded()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        HostConnectionManager.shared.clearCachedHosts()
        
        // When we background we'll remove userLoginTokens, so next time we foreground the app we'll register on livechats again
        HostConnectionManager.shared.clearUserLoginTokens()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        // Save our profile to backend if necessary
        if !isFreshLaunch {
            let userProfile = CacheManager.retrieveUserProfile()
            userProfile?.postToBackendIfNeeded()
        }
        
        let freshLaunch = isFreshLaunch
        
        AuthManager.validateAuth0Session(completion: { [unowned self] (didSucceed, error) in
            guard didSucceed == true else {
                self.logout()
                return
            }
            
            // Retrieve profile from backend, but ignore responses (since if we are logged out, we'll retrieve profile immediately after login anyways)
            AwsBackendManager.getUserProfile()
            
            // If we're re-opening the app, we'll reconnect to all active hosts
            if !freshLaunch {
                HostConnectionManager.shared.connectToAllActiveHosts { [unowned self] (didSucceed: Bool) in
                    guard didSucceed else {
                        DispatchQueue.main.async {
                            guard let vc = self.window?.rootViewController else {
                                return
                            }
                            AlertManager.showError("serverConnectError".localized, controller: vc)
                        }
                        return
                    }
                    
                    // Trigger existing push requests if necessary
                    if let request = self.pushNotificationHandler.existingPushRequest {
                        Constants.Notification.openChatPushRequest(request: request).post()
                        self.pushNotificationHandler.clearExistingPushRequest()
                    }
                }
            }
        })
        
        isFreshLaunch = false
        
        // Reset notification badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Register for remote notifications
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            PushNotifications.registerForPushNotifications()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
    
    // MARK: Push Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationHandler.set(deviceTokenData: deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    // MARK: Other
    
    static func openSearch(_ search: String) {
        if let keyWords = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string:"http://www.google.com/search?q=\(keyWords)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static func callNumber(_ number: String) {
        if let url = URL(string: "tel://\(number)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static func openWebsite(_ address: String!) {
        UIApplication.shared.openURL(URL(string: address)!)
    }
    
    func onReconnectToHost() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.reconnect), object: nil)
//        CRNotifications.showNotification(type: .success, title: "success".localized, message: "reconnect".localized, dismissDelay: 5)
    }
    
    static func logout(withMessage message: String? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.logout(withMessage: message)
    }

    func logout(withMessage message: String? = nil) {
        let showMessageClosure = { (rootVC: UIViewController?) in
            if let m = message {
                let alert = UIAlertController(title: nil, message: m, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    rootVC?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        AuthManager.logout()
        CacheManager.clearUserProfile()
        HostConnectionManager.shared.clearCachedHosts(persist: true)
        pushNotificationHandler.clearExistingPushRequest()
        
        let rootVC = self.window?.rootViewController
        if let navigationController = rootVC as? UINavigationController {
            if !(navigationController.topViewController is LoginViewController) &&
                !(navigationController.topViewController is RegisterViewController) &&
                !(navigationController.topViewController is ResetPassViewController) {
                navigationController.topViewController?.dismiss(animated: true, completion: nil)
                navigationController.popToRootViewController(animated: true)
            }
        }
        if rootVC?.presentedViewController != nil {
            rootVC?.dismiss(animated: true, completion: {
                showMessageClosure(rootVC)
            })
        } else {
            showMessageClosure(rootVC)
        }
    }

    static func get() -> AppDelegate {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        return appDelegate
    }
    
}
