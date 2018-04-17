//
//  LoginViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 25.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import AnimatedTextInput
import UIKit
import Auth0

class LoginViewController: MasaiBaseViewController {
    
    typealias ConnectToHostsClosure = (_ didSucceed: Bool) -> Void
    
    @IBOutlet weak var fbLoginImageView: UIImageView!
    @IBOutlet weak var googleLoginImageView: UIImageView!
    @IBOutlet weak var twitterLoginImageView: UIImageView!
    @IBOutlet weak var linkedinLoginImageView: UIImageView!
    
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var linkedinLoginButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resetPassButton: UIButton!
    
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginTextInput: AnimatedTextInput!
    @IBOutlet weak var passTextInput: AnimatedTextInput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    
    private var socialButtonsloadingIndicator: UIActivityIndicatorView!
    private var socialButtonsLoadingIndicatorConstraints: [NSLayoutConstraint] = []
    
    var currentEditingTextField : AnimatedTextInput?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        
        if let navController = navigationController as? BaseNavigationController {
            navController.hideStatusBarBackgroundView = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: BaseViewController
    
    override func isNavigationBarVisible() -> Bool {
        return false
    }
    
    
    // MARK: Private
    
    private func prepareLayout() {
        resetPassButton.setTitle("resetPass".localized, for: .normal)
        
        loginTextInput.placeHolderText = "login".localized
        loginTextInput.style =  MasaiAnimatedTextInputStyle()
        loginTextInput.delegate = self
        
        passTextInput.placeHolderText = "pass".localized
        passTextInput.style = MasaiAnimatedTextInputStyle()
        passTextInput.type = .password
        passTextInput.delegate = self
        
        titleLabel.text = "login_title".localized
        subtitleLabel.text = "login_subtitle".localized
        registerButton.setTitle("register_button_title".localized, for: .normal)
        orLabel.text = "or".localized
        
        socialButtonsloadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        socialButtonsloadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        socialButtonsloadingIndicator.hidesWhenStopped = true
        view.addSubview(socialButtonsloadingIndicator)
    }
    
    private func validateLoginData() -> Bool {
        var result = true
        if loginTextInput.text == nil || loginTextInput.text == "" {
            loginTextInput.show(error: "emptyLoginError".localized)
            result = false
        }
        
        if passTextInput.text == nil || passTextInput.text == "" {
            passTextInput.show(error: "emptyPassError".localized)
            result = false
        }
        return result
    }
    
    
    // MARK: Statusbar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: UI events
    
    @IBAction func onBackgroundTap(_ sender: UITapGestureRecognizer) {
        if self.currentEditingTextField != nil {
            let _ = self.currentEditingTextField?.resignFirstResponder()
        }
    }
    
    @IBAction func onLoginButtonPressed(_ sender: UIButton) {
        enableLoginButton(false)
        
        // Always re-enable the login button
        defer {
            self.enableLoginButton(true)
        }
        
        guard validateLoginData() else {
            return
        }
        
        // Check for Internet Connection - if no connection is present, directly display error message
        if !ReachabilityManager.shared.isOnline {
            AlertManager.showError("no_internet_connection_alert".localized, controller: self)
            return
        }
        
        guard let login = loginTextInput.text, let pass = passTextInput.text else {
            //TODO: Show error
            return
        }
        
        self.indicator.isHidden = false
        
        AuthManager.loginAuth0(email: login, pass: pass, completion: { [unowned self] (credentials, error) in
            if credentials == nil || error != nil {
                AlertManager.showError(error?.localizedDescription, controller: self)
                DispatchQueue.main.async {
                    self.indicator.isHidden = true
                    self.enableLoginButton(true)
                }
                return
            }
            
            AuthManager.updateUserProfile(completion: { (user: User?, error: Error?, _) in
                if credentials == nil || error != nil {
                    AlertManager.showError("updateProfileError".localized, controller: self)
                    DispatchQueue.main.async {
                        self.indicator.isHidden = true
                        self.enableLoginButton(true)
                    }
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    DispatchQueue.main.async {
                        self.indicator.isHidden = true
                        self.enableLoginButton(true)
                    }
                    
                    if didSucceed {
                        self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                    }
                })
            })
        })
    }
    
    @IBAction func onFacebookLoginButtonPressed(_ sender: UIButton) {
        self.fbLoginButton.isUserInteractionEnabled = false
        showLoadingAnimation(in: fbLoginButton)
        
        AuthManager.loginFacebook { [unowned self] (credentials, error) in
            DispatchQueue.main.async {
                if error != nil {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                    self.fbLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.fbLoginButton)
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    self.fbLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.fbLoginButton)
                    
                    if didSucceed {
                        self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func onGoogleLoginButtonPressed(_ sender: Any) {
        self.googleLoginButton.isUserInteractionEnabled = false
        showLoadingAnimation(in: googleLoginButton)
        
        AuthManager.loginGoogle { [unowned self] (credentials, error) in
            DispatchQueue.main.async {
                if error != nil {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                    self.googleLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.googleLoginButton)
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    self.googleLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.googleLoginButton)
                    
                    if didSucceed {
                        self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func onTwitterLoginButtonPressed(_ sender: Any) {
        self.twitterLoginButton.isUserInteractionEnabled = false
        showLoadingAnimation(in: twitterLoginButton)
        
        AuthManager.loginTwitter { [unowned self] (credentials, error) in
            DispatchQueue.main.async {
                if error != nil {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                    self.twitterLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.twitterLoginButton)
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    self.twitterLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.twitterLoginButton)
                    
                    if didSucceed {
                        self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func onLinkedinLoginButtonPressed(_ sender: Any) {
        self.linkedinLoginButton.isUserInteractionEnabled = false
        showLoadingAnimation(in: linkedinLoginButton)
        
        AuthManager.loginLinkedIn { [unowned self] (credentials, error) in
            DispatchQueue.main.async {
                if error != nil {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                    self.linkedinLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.linkedinLoginButton)
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    self.linkedinLoginButton.isUserInteractionEnabled = true
                    self.hideLoadingAnimation(in: self.linkedinLoginButton)
                    
                    if didSucceed {
                        self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func onRegisterButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.loginToRegister, sender: nil)
    }
    
    @IBAction func onResetPassButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.loginToResetPass, sender: nil)
    }
    
    
    // MARK: Private
    
    private func showLoadingAnimation(in button: UIButton) {
        imageView(for: button)?.alpha = 0.4
        view.removeConstraints(socialButtonsLoadingIndicatorConstraints)
        socialButtonsLoadingIndicatorConstraints = socialButtonsloadingIndicator.pinCenter(to: button)
        socialButtonsLoadingIndicatorConstraints.activate()
        socialButtonsloadingIndicator.startAnimating()
    }
    
    private func hideLoadingAnimation(in button: UIButton) {
        socialButtonsloadingIndicator.stopAnimating()
        imageView(for: button)?.alpha = 1.0
    }
    
    private func imageView(for button: UIButton) -> UIImageView? {
        if button == fbLoginButton {
            return fbLoginImageView
        } else if button == googleLoginButton {
            return googleLoginImageView
        } else if button == twitterLoginButton {
            return twitterLoginImageView
        } else if button == linkedinLoginButton {
            return linkedinLoginImageView
        }
        
        return nil
    }
    
    private func enableLoginButton(_ shouldEnable: Bool) {
        self.loginButton.isUserInteractionEnabled = shouldEnable
    }
    
    private func connectToHosts(_ completion: @escaping ConnectToHostsClosure) {
        HostConnectionManager.shared.prepareHostList {
            HostConnectionManager.shared.connectToAllActiveHosts { [unowned self] (didSucceed) -> (Void) in
                if !didSucceed {
                    AlertManager.showError("serverConnectError".localized, controller: self)
                }
                
                DispatchQueue.main.async {
                    completion(didSucceed)
                }
            }
        }
    }
}

extension LoginViewController : AnimatedTextInputDelegate {
    
    func animatedTextInputDidBeginEditing(animatedTextInput: AnimatedTextInput) {
        animatedTextInput.clearError()
        self.currentEditingTextField = animatedTextInput
    }
    
    func animatedTextInputDidEndEditing(animatedTextInput: AnimatedTextInput) {
        self.currentEditingTextField = nil
    }
    
    func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool {
        
        if let nextInput = self.view.viewWithTag(animatedTextInput.tag + 1) as? AnimatedTextInput {
            let _ = nextInput.becomeFirstResponder()
        } else {
            let _ = animatedTextInput.resignFirstResponder()
        }
        
        return true
    }
}
