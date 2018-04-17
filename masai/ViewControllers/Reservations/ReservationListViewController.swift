//
//  ReservationListViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 02.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class ReservationListViewController: MasaiBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var reservationList = [ReservationListData]()
    var selectedData: ReservationListData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "reservations".localized
        prepareReservationData()
        registerCellForTableView()
    }
    
    private func prepareReservationData() {
        let reservations = ReservationDataManager.reservationList()
        var previousDate: Date?
        for reservation in reservations {
            if let reservationDate = reservation.reservationDate(), let previousDate = previousDate, Calendar.current.isDate(previousDate, inSameDayAs:reservationDate) {
                self.reservationList.append(reservation)
            } else if let reservationDate = reservation.reservationDate() {
                self.reservationList.append(Timeline(reservationDate))
                previousDate = reservationDate
                self.reservationList.append(reservation)
            }
        }
    }
    
    private func registerCellForTableView() {
        self.tableView.register(UINib(nibName: TimelineTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TimelineTableViewCell.identifier)
         self.tableView.register(UINib(nibName: HotelTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: HotelTableViewCell.identifier)
         self.tableView.register(UINib(nibName: FlightTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: FlightTableViewCell.identifier)
         self.tableView.register(UINib(nibName: PublicTransportTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PublicTransportTableViewCell.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.reservationToHotelDetails {
            if let hotelDetailsVC = segue.destination as? ReservationDetailsHotelViewController, let hotelData = selectedData as? Hotel {
//                hotelDetailsVC.hotelData = hotelData
            }
        } else if segue.identifier == Constants.Segue.reservationToFlightDetails {
            if let flightDetailsVC = segue.destination as? ReservationDetailsFlightViewController, let flightData = selectedData as? Flight {
//                flightDetailsVC.flightData = flightData
            }
        } else if segue.identifier == Constants.Segue.reservationToPublicTransportDetails {
            if let publicTransportVC = segue.destination as? ReservationDetailsPublicTransportViewController, let publicTransportData = selectedData as? PublicTransport {
//                publicTransportVC.publicTransportData = publicTransportData
            }
        }
    }
}


extension ReservationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let listData = self.reservationList[indexPath.row]
        if listData.reservationDataType() == .reservation {
                return 90.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reservationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listData =  self.reservationList[indexPath.row]
        if listData.reservationDataType() == .timeline, let data = listData as? Timeline, let date = data.date {
            let cell = tableView.dequeueReusableCell(withIdentifier: TimelineTableViewCell.identifier) as! TimelineTableViewCell
            cell.dateLabel.text = Date.reservationDateString(date)
            return cell
        } else if listData.reservationDataType() == .reservation, let data = listData as? ReservationBaseModel {
            
            switch data.reservationType() {
            case .flight:
                let flightData = data as! Flight
                let cell = tableView.dequeueReusableCell(withIdentifier: FlightTableViewCell.identifier) as! FlightTableViewCell
                cell.arrivalLabel.text = flightData.arrival.name
                cell.departuesLabel.text = flightData.departue.name
                return cell
            case.hotel:
                let hotelData = data as! Hotel
                let cell = tableView.dequeueReusableCell(withIdentifier: HotelTableViewCell.identifier) as! HotelTableViewCell
                cell.hotelNameLabel.text = hotelData.hotelName
                cell.hotelAddressLabel.text = hotelData.address.street
                return cell
            case .publicTransport:
                let transportData =  data as! PublicTransport
                let cell = tableView.dequeueReusableCell(withIdentifier: PublicTransportTableViewCell.identifier) as! PublicTransportTableViewCell
                cell.arrivalLabel.text = transportData.arrival.name
                cell.departureLabel.text = transportData.departure.name
                return cell
            case .none:
                break
            }
        }
    
        return UITableViewCell()
    }
    
}

extension ReservationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedData = self.reservationList[indexPath.row]
        
        if selectedData is Hotel {
            performSegue(withIdentifier: Constants.Segue.reservationToHotelDetails, sender: nil)
        } else if selectedData is Flight {
            performSegue(withIdentifier: Constants.Segue.reservationToFlightDetails, sender: nil)
        } else if selectedData is PublicTransport {
            performSegue(withIdentifier: Constants.Segue.reservationToPublicTransportDetails, sender: nil)
        }
    }
}
