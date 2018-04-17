//
//  ReservationDetailsFlightViewController.swift
//  masai
//
//  Created by Florian Rath on 29.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import UIKit
import MessageUI

class ReservationDetailsCarViewController: MasaiBaseViewController  {
    
    // Titles
    @IBOutlet weak var carTypeTitleLabel: UILabel!
    @IBOutlet weak var pickupDateTitleLabel: UILabel!
    @IBOutlet weak var pickupAddressTitleLabel: UILabel!
    @IBOutlet weak var dropoffDateTitleLabel: UILabel!
    @IBOutlet weak var dropoffAddressTitleLabel: UILabel!
    @IBOutlet weak var confirmationNumberTitleLabel: UILabel!
    
    
    // Content
    @IBOutlet weak var carCompanyLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var dropoffDateLabel: UILabel!
    @IBOutlet weak var dropoffAddressLabel: UILabel!
    @IBOutlet weak var confirmationNumberLabel: UILabel!
    
    var segment: CarSegment!
    
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
        carCompanyLabel.text = segment.carCompany
        if segment.pickupCityName == segment.dropoffCityName {
            cityLabel.text = segment.pickupCityName
        } else {
            cityLabel.text = "\(segment.pickupCityName ?? "") - \(segment.dropoffCityName ?? "")"
        }
        carTypeLabel.text = segment.carType
        pickupDateLabel.text = "\(segment.userFacingStartDateString ?? "") \(segment.userFacingStartTimeString ?? "")"
        pickupAddressLabel.text = "\(fullPickupAddress)"
        dropoffDateLabel.text = "\(segment.userFacingEndDateString ?? "") \(segment.userFacingEndTimeString ?? "")"
        dropoffAddressLabel.text = "\(fullDropoffAddress)"
        confirmationNumberLabel.text = segment.confirmationNo
        
        title = "car".localized
        carTypeTitleLabel.text = "car_type".localized
        pickupDateTitleLabel.text = "pickup_date".localized
        pickupAddressTitleLabel.text = "pickup_address".localized
        dropoffDateTitleLabel.text = "dropoff_date".localized
        dropoffAddressTitleLabel.text = "dropoff_address".localized
        confirmationNumberTitleLabel.text = "confirmation_number".localized
    }
    
    var fullPickupAddress: String {
        var str = "\(segment.pickupCityName ?? "")\n"
        str += "\(segment.pickupAddress1 ?? "")"
        if let address = segment.pickupAddress2 {
            str += "\n\(address)"
        }
        str += "\n"
        str += "\(segment.pickupPostalCode ?? "") \(segment.pickupCountry ?? "")"
        return str
    }
    
    var fullDropoffAddress: String {
        var str = "\(segment.dropoffCityName ?? "")\n"
        str += "\(segment.dropoffAddress1 ?? "")"
        if let address = segment.dropoffAddress2 {
            str += "\n\(address)"
        }
        str += "\n"
        str += "\(segment.dropoffPostalCode ?? "") \(segment.dropoffCountry ?? "")"
        return str
    }

}
