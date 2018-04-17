//
//  SplashViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class SplashViewController: MasaiBaseViewController {
    
    // MARK: Types
    
    typealias CanAutologinClosure = (_ canAutoLogin: Bool) -> Void
    
    
    // MARK: Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var masaiLogo: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    private var _canAutoLogin: Bool?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        
        if let navController = navigationController as? BaseNavigationController {
            navController.hideStatusBarBackgroundView = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingLabel.text = "splashscreen_loading_text".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectToChat()
        self.activityIndicator.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _canAutoLogin = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: MasaiBaseViewController
    
    override func isNavigationBarVisible() -> Bool {
        return false
    }
    
    private func prepareLayout() {
        self.masaiLogo.image = self.masaiLogo.image!.withRenderingMode(.alwaysTemplate)
        self.masaiLogo.tintColor = .orangeMasai
    }
    
    
    // MARK: Private
    
    private func connectToChat() {
        HostConnectionManager.shared.prepareHostList { [unowned self] in
            
            self.canAutoLogin({ (can) in
                if can {
                    HostConnectionManager.shared.connectToAllActiveHosts { (didSucceed: Bool) -> (Void) in
                        if didSucceed {
                            self.autologin()
                            return
                        } else {
                            DispatchQueue.main.async {
                                AlertManager.showError("serverConnectError".localized, controller: self)
                                if !(self.navigationController?.topViewController?.isKind(of: LoginViewController.self))! {
                                    self.performSegue(withIdentifier: Constants.Segue.splashToLogin, sender: nil)
                                }
                            }
                        }
                    }
                    return
                }
                
                self.autologin()
            })
            
            
        }
    }
    
    private func canAutoLogin(_ completion: @escaping CanAutologinClosure) {
        if let can = _canAutoLogin {
            DispatchQueue.main.async {
                completion(can)
            }
            return
        }
        
        AuthManager.validateAuth0Session(completion: { [unowned self] (success, error) in
            self._canAutoLogin = success
            
            DispatchQueue.main.async {
                completion(self._canAutoLogin!)
            }
        })
    }
    
    private func autologin() {
        canAutoLogin { [unowned self] (can) in
            if can {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Constants.Segue.splashToMain, sender: nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    if !(self.navigationController?.topViewController?.isKind(of: LoginViewController.self))! {
                        self.performSegue(withIdentifier: Constants.Segue.splashToLogin, sender: nil)
                    }
                }
            }
        }
    }
}
