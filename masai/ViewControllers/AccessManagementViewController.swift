//
//  AccessManagementViewController.swift
//  masai
//
//  Created by Florian Rath on 26.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit


class AccessManagementViewController: MasaiBaseViewController {
    
    // MARK: Properties
    
    private var grants: [AccessGrant] = [] {
        didSet {
            updateUI()
        }
    }
    
    
    // MARK: UI
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 12)
        return l
    }()
    
    private let revokeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        b.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        b.heightAnchor.constraint(equalToConstant: 38).isActive = true
        b.setTitle("profile_access_revokebutton".localized, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        b.backgroundColor = UIColor.dbRed
        b.layer.cornerRadius = 4.0
        b.setTitleColor(UIColor.white, for: .normal)
        return b
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "icon-lock-open")
        return iv
    }()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showLoadingAnimation(true)
        
        AwsBackendManager.getAccessGrants { [weak self] (didSucceed, grants) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.showLoadingAnimation(false)
            strongSelf.grants = grants ?? []
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        title = "profile_access_title".localized
        
        view.backgroundColor = .white
        
        view.addSubview(loadingIndicator)
        loadingIndicator.pinCenter(to: view).activate()
        
        view.addSubview(label)
        label.pin.edges([.leading, .trailing]).to(view).with(constants: [16, -16]).activate()
        label.pin.top.to(view.centerYAnchor).activate()
        
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.pin.bottom.to(label.topAnchor).with(-8).activate()
        
        view.addSubview(revokeButton)
        revokeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        revokeButton.pin.top.to(label.bottomAnchor).with(16).activate()
        revokeButton.isHidden = true
        
        revokeButton.addTarget(self, action: #selector(self.revokeButtonPressed(_:)), for: .touchUpInside)
    }
    
    
    // MARK: UI events
    
    @objc private func revokeButtonPressed(_ sender: Any) {
        showLoadingAnimation(true)
        
        AwsBackendManager.deleteAccessGrants(grants) { [weak self] (didSucceed, newGrants) in
            if !didSucceed {
                //TODO: Show error message
            }
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.grants = newGrants ?? []
            strongSelf.showLoadingAnimation(false)
        }
    }
    
    
    // MARK: Private
    
    private func showLoadingAnimation(_ shouldShow: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if shouldShow {
                strongSelf.loadingIndicator.startAnimating()
                strongSelf.view.alpha = 0.9
                strongSelf.view.isUserInteractionEnabled = false
            } else {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.view.alpha = 1.0
                strongSelf.view.isUserInteractionEnabled = true
            }
        }
    }
    
    private func updateUI() {
        if grants.count > 0 {
            
            label.text = String(format: "user_access_count".localized, grants.count)
            revokeButton.isHidden = false
            imageView.image = #imageLiteral(resourceName: "icon-lock-open")
        } else {
            label.text = "profile_access_no_foreign_access".localized
            revokeButton.isHidden = true
            imageView.image = #imageLiteral(resourceName: "icon-lock-closed")
        }
    }
    
}
