//
//  MoreViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 26.04.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class MoreViewController: MasaiBaseViewController {

    @IBOutlet weak var titlelabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "more_title".localized
        self.titlelabel.text = "comingSoon".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
