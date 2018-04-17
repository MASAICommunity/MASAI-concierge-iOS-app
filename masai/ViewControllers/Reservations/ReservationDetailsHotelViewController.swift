//
//  ReservationDetailsHotelViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 03.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class ReservationDetailsHotelViewController: MasaiBaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    // Titles
    @IBOutlet weak var checkInTitleLabel: UILabel!
    @IBOutlet weak var checkOutTitleLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var confirmationNumberTitleLabel: UILabel!
    
    // Values
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var confirmationNumberLabel: UILabel!
    
    var segment: HotelSegment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotationToMap()
        fillViewWithData()
        title = segment.hotelName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func fillViewWithData() {
        self.addresLabel.text = segment.cityName
        
        if let confirmationNumber = segment.confirmationNo {
            self.confirmationNumberLabel.text = confirmationNumber
        }
        
        checkInLabel.text = segment.userFacingStartDateString
        checkOutLabel.text = segment.userFacingEndDateString
        
        durationLabel.text = "\(fullAddress)"
        
        checkInTitleLabel.text = "check_in".localized
        checkOutTitleLabel.text = "check_out".localized
        addressTitleLabel.text = "address".localized
        confirmationNumberTitleLabel.text = "confirmation_number".localized
    }

    private func addAnnotationToMap() {
        if let lat = segment.lat,
            let latValue = Double(lat),
            let long = segment.lon,
            let lonValue = Double(long) {
            let hotelAnnotation = PlaceAnnotationView(lat: latValue, long: lonValue)
            self.mapView.addAnnotation(hotelAnnotation)
            
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = hotelAnnotation.coordinate
            mapRegion.span.latitudeDelta = 0.008;
            mapRegion.span.longitudeDelta = 0.008;
            mapView.setRegion(mapRegion, animated: false)
        }
    }
    
    @IBAction func onNaviagtionButtonPressed(_ sender: Any) {
        if let lat = segment.lat,
            let latValue = Double(lat),
            let long = segment.lon,
            let lonValue = Double(long) {
            let cords = CLLocationCoordinate2DMake(latValue, lonValue)
            openNavigationApp(cords, placeName: segment.hotelName)
        }
    }
  
    private func openNavigationApp(_ cords: CLLocationCoordinate2D, placeName: String?) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = cords
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }
    
    var fullAddress: String {
        var str = "\(segment.cityName ?? "")\n"
        str += "\(segment.address1 ?? "")"
        if let address = segment.address2 {
            str += "\n\(address)"
        }
        str += "\n"
        str += "\(segment.postalCode ?? "") \(segment.country ?? "")"
        return str
    }
    
}
extension ReservationDetailsHotelViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
}
