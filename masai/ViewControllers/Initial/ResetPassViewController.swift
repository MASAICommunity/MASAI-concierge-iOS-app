//
//  ResetPassViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 09.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import AnimatedTextInput

class ResetPassViewController: MasaiBaseViewController {

    @IBOutlet weak var resetPassButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: AnimatedTextInput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backToLoginButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var currentEditingTextField: AnimatedTextInput?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareLayout()
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
        self.emailTextField.style = MasaiAnimatedTextInputStyle()
        self.emailTextField.delegate = self
        self.emailTextField.placeHolderText = "email".localized
        
        titleLabel.text = "reset_password_title".localized
        backToLoginButton.setTitle("back_to_login".localized, for: .normal)
        resetButton.setTitle("reset_password_button".localized, for: .normal)
    }
    
    private func validateEmail() -> Bool {
        if emailTextField.text == nil || emailTextField.text?.isValidEmail() == false {
            emailTextField.show(error: "emailError".localized)
            return false
        }
        return true
    }
    
    
    // MARK: UI events
    
    @IBAction func onBackToLoginButtonPressed(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onResetPassButtonPressed(_ sender: UIButton) {
        guard validateEmail()  else {
            return
        }
        
        if let emailToReset = self.emailTextField.text {
            self.activityIndicator.isHidden = false
            self.resetPassButton.isUserInteractionEnabled = false
            AuthManager.resetAuth0Pass(emailToReset, completion: { (success) in
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    if success {
                        AlertManager.showInfo("resetPassSuccessfully".localized, controller: self, handler: { _ in
                            let _ = self.currentEditingTextField?.resignFirstResponder()
                            let _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        AlertManager.showInfo("resetPassError".localized, controller: self, handler: nil)
                    }
                    self.resetPassButton.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    @IBAction func onBackgroundTap(_ sender: Any) {
        if currentEditingTextField != nil {
            let _ = currentEditingTextField?.resignFirstResponder()
        }
    }
    
    
    // MARK: Statusbar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ResetPassViewController : AnimatedTextInputDelegate {
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



