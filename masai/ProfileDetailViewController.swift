//
//  ProfileDetailViewController.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import Auth0


class ProfileDetailViewController: MasaiBaseViewController {
    
    // MARK: Types
    
    typealias LoadFormClosure = ((_ viewController: ProfileDetailViewController)->Void)
    
    
    // MARK: Properties
    
    var loadFormClosure: LoadFormClosure?
    
    private var didSetupForms = false
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.hidesWhenStopped = true
        return a
    }()
    
    private var notificationToken: Any? = nil
    
    private var profile: UserProfile!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "profile_title".localized
        
        profile = CacheManager.retrieveUserProfile() ?? UserProfile()
        
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNotifications()
        
        DispatchQueue.global(qos: .default).async { [unowned self] in
            self.setup()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        profile.postToBackendIfNeeded(andSaveLocally: true)
        
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
            notificationToken = nil
        }
    }
    
    
    // MARK: Setup
    
    private func setup() {
        DispatchQueue.main.sync { [unowned self] in
            self.view.backgroundColor = UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
        }
        
        guard didSetupForms == false else {
            return
        }
        
        DispatchQueue.main.sync { [unowned self] in
            self.loadingIndicator.startAnimating()
        }
        
        DispatchQueue.main.sync { [unowned self] in
            self.loadFormClosure?(self)
            
            self.loadingIndicator.stopAnimating()
        }
        
        didSetupForms = true
    }
    
    private func setupNotifications() {
        if notificationToken == nil {
            notificationToken = NotificationCenter.default.addObserver(forName: FormNotifications.formValueChanged, object: nil, queue: OperationQueue.main) { [unowned self] (notification) in
                guard let userInfo = notification.userInfo,
                    let form = userInfo["form"] as? Form else {
                        return
                }
                
                self.profile.update(from: form.values)
                CacheManager.save(userProfile: self.profile)
            }
        }
    }
    
}
