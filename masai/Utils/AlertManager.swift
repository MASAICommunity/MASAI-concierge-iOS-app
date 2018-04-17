//
//  AlertManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 31.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation
import UIKit

struct AlertManager {
    
    static func showError(_ message: String?, controller: UIViewController, title: String? = "error".localized, completion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "ok".localized , style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            controller.present(alertController, animated: true, completion: completion)
        }
    }
    
    static func showInfo(_ message: String?, controller: UIViewController, title: String? = "info".localized, completion: (() -> Void)? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "ok".localized , style: .default, handler: handler))
        
        DispatchQueue.main.async {
            controller.present(alertController, animated: true, completion: completion)
        }
    }
    
    static func askAboutPermission(_ controller: UIViewController, onAccess:((UIAlertAction) -> Void)?, onDenied: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: "travelFolderAccessTitle".localized, message:"travelFolderAccesMessage".localized , preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "yes".localized , style: .default, handler: onAccess))
        alertController.addAction(UIAlertAction.init(title: "no".localized , style: .destructive, handler: onDenied))
        
        DispatchQueue.main.async {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func askToFillOutMandatoryProfileFields(_ controller: UIViewController, yesClosure: ((UIAlertAction) -> Void)? = nil, noClosure: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "travelFolderAccess_ProfileFieldsQuestionTitle".localized, message: "travelFolderAccess_ProfileFieldsQuestionBody".localized , preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localized , style: .default, handler: yesClosure))
        alertController.addAction(UIAlertAction(title: "no".localized , style: .destructive, handler: noClosure))
        
        DispatchQueue.main.async {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
