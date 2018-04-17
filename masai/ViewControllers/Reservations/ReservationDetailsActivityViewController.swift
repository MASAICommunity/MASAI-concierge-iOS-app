//
//  ReservationDetailsFlightViewController.swift
//  masai
//
//  Created by Florian Rath on 29.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit
import MessageUI

class ReservationDetailsActivityViewController: MasaiBaseViewController  {
    
    // Titles
    @IBOutlet weak var beginTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var travellersTitleLabel: UILabel!
    @IBOutlet weak var confirmationNumberTitleLabel: UILabel!
    
    // Content
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var beginLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var travellersLabel: UILabel!
    @IBOutlet weak var confirmationNumberLabel: UILabel!
    
    var segment: ActivitySegment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fillViewWithData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func fillViewWithData() {
        cityNameLabel.text = segment.startCityName
        activityNameLabel.text = segment.activityName
        
        beginLabel.text = "\(segment.userFacingStartDateString ?? "") \(segment.userFacingStartTimeString ?? "")\n\(fullStartAddress)"
        endLabel.text = "\(segment.userFacingEndDateString ?? "") \(segment.userFacingEndTimeString ?? "")\n\(fullEndAddress)"
        
        travellersLabel.text = (segment.travelers?.flatMap({ $0.name }) ?? []).joined(separator: "\n")
        confirmationNumberLabel.text = segment.confirmationNo
        
        title = "activity".localized
        beginTitleLabel.text = "begins".localized
        endTitleLabel.text = "ends".localized
        travellersTitleLabel.text = "participants".localized
        confirmationNumberTitleLabel.text = "confirmation_number".localized
    }
    
    var fullStartAddress: String {
        var str = "\(segment.startCityName ?? "")\n"
        str += "\(segment.startAddress1 ?? "")"
        if let address = segment.startAddress2 {
            str += "\n\(address)"
        }
        str += "\n"
        str += "\(segment.startPostalCode ?? "") \(segment.startCountry ?? "")"
        return str
    }
    
    var fullEndAddress: String {
        var str = "\(segment.endCityName ?? "")\n"
        str += "\(segment.endAddress1 ?? "")"
        if let address = segment.endAddress2 {
            str += "\n\(address)"
        }
        str += "\n"
        str += "\(segment.endPostalCode ?? "") \(segment.endCountry ?? "")"
        return str
    }

}
