//
//  ReservationDetailsPublicTransportViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class ReservationDetailsPublicTransportViewController: MasaiBaseViewController {

    // Titles
    @IBOutlet weak var fromTitleLabel: UILabel!
    @IBOutlet weak var toTitleLabel: UILabel!
    
    @IBOutlet weak var departsLabel: UILabel!
    @IBOutlet weak var arrivesLabel: UILabel!
    
    @IBOutlet weak var ticketsTitleLabel: UILabel!
    @IBOutlet weak var PassengersTitleLabel: UILabel!
    @IBOutlet weak var seatsTitleLabel: UILabel!
    
    @IBOutlet weak var confirmationNrTitleLabel: UILabel!
    @IBOutlet weak var ticketNrTitleLabel: UILabel!
    
    // Values
    @IBOutlet weak var trainNameLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
   
    @IBOutlet weak var departsTime: UILabel!
    @IBOutlet weak var arrivesTimeLabel: UILabel!
    
    @IBOutlet weak var travelDurationLabel: UILabel!
    @IBOutlet weak var passengerNameLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var ticketNumberLabel: UILabel!
    
    var segment: TrainSegment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillViewWithData()
    }

    private func fillViewWithData() {
        title = "\(segment.railLine ?? "") \(segment.trainNumber ?? "")"
        self.trainNameLabel.text = title
        
        self.fromLabel.text = segment.originName ?? segment.origin ?? segment.originCityName ?? ""
        self.toLabel.text = segment.destinationName ?? segment.destination ?? segment.destinationCityName ?? ""
        
        self.departsTime.text = segment.userFacingStartTimeString
        
        self.arrivesTimeLabel.text = segment.userFacingEndTimeString
        
        self.travelDurationLabel.text = segment.tickets?.joined(separator: ", ") ?? ""
        
        passengerNameLabel.text = (segment.travelers?.flatMap({ $0.name }) ?? []).joined(separator: "\n")
        
        seatLabel.text = segment.seats?.joined(separator: ", ")
        
        confirmationLabel.text = segment.confirmationNo
        
        ticketNumberLabel.text = segment.ticketNumber
        
        self.departsLabel.text = "departs".localized + " \(segment.userFacingStartDateString ?? "")"
        self.arrivesLabel.text = "arrives".localized + " \(segment.userFacingEndDateString ?? "")"
        fromTitleLabel.text = "from".localized
        toTitleLabel.text = "to".localized
        ticketsTitleLabel.text = "tickets".localized
        PassengersTitleLabel.text = "passengers".localized
        seatsTitleLabel.text = "seats".localized
        confirmationNrTitleLabel.text = "confirmation_number".localized
        ticketNrTitleLabel.text = "ticket_number".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
