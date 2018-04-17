//
//  MasaiBaseViewController.swift
//  masai
//
//  Created by Florian Rath on 19.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class MasaiBaseViewController: BaseViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: Statusbar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
