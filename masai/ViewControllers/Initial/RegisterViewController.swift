//
//  RegisterViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 30.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import AnimatedTextInput
import UIKit

class RegisterViewController: MasaiBaseViewController {
    
    typealias ConnectToHostsClosure = (_ didSucceed: Bool) -> Void
    
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var linkedinLoginButton: UIButton!
    
    @IBOutlet weak var registerTitle: UILabel!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var firstNameTextInput: AnimatedTextInput!
    @IBOutlet weak var lastNameTextInput: AnimatedTextInput!
    @IBOutlet weak var emailTextInput: AnimatedTextInput!
    @IBOutlet weak var passTextInput: AnimatedTextInput!
    @IBOutlet weak var repeatTextInput: AnimatedTextInput!
    
    @IBOutlet weak var registerContentView: UIView!
    
    var currentEditingTextField: AnimatedTextInput?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        
        
        // Hide social login options
        for view in socialView.subviews {
            view.isHidden = true
        }
        socialView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        backToLoginButton.topAnchor.constraint(equalTo: registerContentView.bottomAnchor, constant: 8.0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Private
    
    private func prepareLayout() {
        firstNameTextInput.placeHolderText = "first_name".localized
        firstNameTextInput.style =  MasaiAnimatedTextInputStyle()
        firstNameTextInput.delegate = self
        
        lastNameTextInput.placeHolderText = "last_name".localized
        lastNameTextInput.style =  MasaiAnimatedTextInputStyle()
        lastNameTextInput.delegate = self
        
        emailTextInput.placeHolderText = "email".localized
        emailTextInput.style =  MasaiAnimatedTextInputStyle()
        emailTextInput.delegate = self
        
        passTextInput.placeHolderText = "pass".localized
        passTextInput.style = MasaiAnimatedTextInputStyle()
        passTextInput.type = .password
        passTextInput.delegate = self
        
        repeatTextInput.placeHolderText = "repeatPass".localized
        repeatTextInput.style =  MasaiAnimatedTextInputStyle()
        repeatTextInput.type = .password
        repeatTextInput.delegate = self
        
        registerTitle.text = "register".localized
        backToLoginButton.setTitle("back_to_login".localized, for: .normal)
        registerButton.setTitle("register".localized, for: .normal)

        
        
    }
    
    private func validateRegisterForm() -> Bool {
        var result = true
        
        if firstNameTextInput.text == nil || firstNameTextInput.text == "" {
            firstNameTextInput.show(error: "emptyFirstnameError".localized)
            result = false
        }
        
        if lastNameTextInput.text == nil || lastNameTextInput.text == "" {
            lastNameTextInput.show(error: "emptyLastnameError".localized)
            result = false
        }
        
        if emailTextInput.text == nil || emailTextInput.text?.isValidEmail() == false {
            emailTextInput.show(error: "emailError".localized)
            result = false
        }
        
        if passTextInput.text == nil || passTextInput.text == "" {
            passTextInput.show(error: "emptyPassError".localized)
            result = false
        } else if passTextInput.text != repeatTextInput.text {
            repeatTextInput.show(error: "passError".localized)
            passTextInput.show(error: "passError".localized)
            result = false
        }
        
        return result
    }
    
    private func registerUser() {
        self.activityIndicator.isHidden = false
        self.registerButton.isUserInteractionEnabled = false
        
        guard let firstname = firstNameTextInput.text,
            let lastname = lastNameTextInput.text,
            let pass = passTextInput.text,
            let email = emailTextInput.text else {
            //TODO: Show error message
            self.activityIndicator.isHidden = true
            self.registerButton.isUserInteractionEnabled = true
            return
        }
        
        AuthManager.registerAuth0(email: email, pass: pass, firstName: firstname, lastName: lastname, completion: { (credentials, error) in
            DispatchQueue.main.async {
                guard credentials != nil && error == nil else {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                    self.activityIndicator.isHidden = true
                    self.registerButton.isUserInteractionEnabled = true
                    return
                }
                
                self.connectToHosts({ (didSucceed: Bool) in
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.registerButton.isUserInteractionEnabled = true
                    }
                    
                    if didSucceed {
                        self.navigationController?.popViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33, execute: {
                            self.performSegue(withIdentifier: Constants.Segue.registerToMain, sender: nil)
                        })
                    }
                })
                
                
            }
        })
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
    
    
    // MARK: UI events
    
    @IBAction func onBackgroundTap(_ sender: Any) {
        if currentEditingTextField != nil {
            let _ = currentEditingTextField?.resignFirstResponder()
        }
    }
    
    @IBAction func onRegisterButtonPressed(_ sender: UIButton) {
        guard validateRegisterForm() else {
            return
        }
        
        self.registerUser()
    }
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFacebookLoginButtonPressed(_ sender: UIButton) {
        self.fbLoginButton.isUserInteractionEnabled = false
        AuthManager.loginFacebook { (credentials, error) in
            DispatchQueue.main.async {
                self.fbLoginButton.isUserInteractionEnabled = true
                if error == nil {
                    self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                } else {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                }
            }
        }
    }
    
    @IBAction func onGoogleLoginButtonPressed(_ sender: Any) {
        self.googleLoginButton.isUserInteractionEnabled = false
        AuthManager.loginGoogle { (credentials, error) in
            DispatchQueue.main.async {
                self.googleLoginButton.isUserInteractionEnabled = true
                if error == nil {
                    self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                } else {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                }
            }
        }
    }
    
    @IBAction func onTwitterLoginButtonPressed(_ sender: Any) {
        self.twitterLoginButton.isUserInteractionEnabled = false
        AuthManager.loginTwitter { (credentials, error) in
            DispatchQueue.main.async {
                self.twitterLoginButton.isUserInteractionEnabled = true
                if error == nil {
                    self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                } else {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                }
            }
        }
    }
    
    @IBAction func onLinkedinLoginButtonPressed(_ sender: Any) {
        self.linkedinLoginButton.isUserInteractionEnabled = false
        AuthManager.loginLinkedIn { (credentials, error) in
            DispatchQueue.main.async {
                self.linkedinLoginButton.isUserInteractionEnabled = true
                if error == nil {
                    self.performSegue(withIdentifier: Constants.Segue.loginToMain, sender: nil)
                } else {
                    AlertManager.showError(error?.localizedDescription, controller: self)
                }
            }
        }
    }
    
    
    // MARK: Statusbar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension RegisterViewController : AnimatedTextInputDelegate {
    
    func animatedTextInputDidBeginEditing(animatedTextInput: AnimatedTextInput) {
        self.currentEditingTextField = animatedTextInput
        animatedTextInput.clearError()
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


