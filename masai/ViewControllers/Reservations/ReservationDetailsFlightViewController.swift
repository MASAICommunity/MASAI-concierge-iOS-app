//
//  ReservationDetailsFlightViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import MessageUI

class ReservationDetailsFlightViewController: MasaiBaseViewController  {
    
    // Titles
    @IBOutlet weak var departsLabel: UILabel!
    @IBOutlet weak var arrivesLabel: UILabel!
    @IBOutlet weak var ticketsTitleLabel: UILabel!
    @IBOutlet weak var passengersTitleLabel: UILabel!
    @IBOutlet weak var seatsTitleLabel: UILabel!
    @IBOutlet weak var confirmationNrTitleLabel: UILabel!
    
    // Content
    @IBOutlet weak var flightNameLabel: UILabel!
    
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    
    @IBOutlet weak var departsTimeLabel: UILabel!
    @IBOutlet weak var arrivesTimeLabel: UILabel!
    
    @IBOutlet weak var ticketsLabel: UILabel!
    
    @IBOutlet weak var passengerNameLabel: UILabel!
    
    @IBOutlet weak var seatLabel: UILabel!
    
    @IBOutlet weak var confirmationLabel: UILabel!
    
    var segment: FlightSegment!
    
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
        title = "\(segment.normalizedAirline ?? "") \(segment.flightNumber ?? "")"
        
        flightNameLabel.text = "\(segment.airline ?? "") \(segment.flightNumber ?? "")"
        departureLabel.text = segment.origin?.uppercased() ?? ""
        arrivalLabel.text = segment.destination?.uppercased() ?? ""
        
        departsTimeLabel.text = segment.userFacingStartTimeString
        
        arrivesTimeLabel.text = segment.userFacingEndTimeString
        
        ticketsLabel.text = segment.tickets?.joined(separator: ", ") ?? ""
        
        passengerNameLabel.text = (segment.travelers?.flatMap({ $0.name }) ?? []).joined(separator: "\n")
        
        seatLabel.text = segment.seats?.joined(separator: ", ")

        confirmationLabel.text = segment.confirmationNo
        
        departsLabel.text = "departs".localized + " \(segment.userFacingStartDateString ?? "")"
        arrivesLabel.text = "arrives".localized + " \(segment.userFacingEndDateString ?? "")"
        ticketsTitleLabel.text = "tickets".localized
        passengersTitleLabel.text = "passengers".localized
        seatsTitleLabel.text = "seats".localized
        confirmationNrTitleLabel.text = "confirmation_number".localized
    }

}
