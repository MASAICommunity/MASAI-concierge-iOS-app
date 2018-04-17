//
//  SelectLocationViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

typealias SelectLocationCompletionBlock = (CLLocationCoordinate2D?) -> Void

class SelectLocationViewController: MasaiBaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let updateLocationTimeInterval: TimeInterval = 20.0
    let locationManager = CLLocationManager()
    var selectedLocation: CLLocationCoordinate2D?
    var completion: SelectLocationCompletionBlock?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func centerMap(_ center:CLLocationCoordinate2D) {
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpanMake(Constants.Map.defaultLatitudeDelta, Constants.Map.defaultLongitudeDelta))
        self.mapView.setRegion(newRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocalization = manager.location!.coordinate
        self.selectedLocation = userLocalization
        let annotation = PlaceAnnotationView(lat: userLocalization.latitude, long: userLocalization.longitude)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        centerMap(userLocalization)
        pauseUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.shadowColor = UIColor.greyMasai.cgColor
        self.contentView.layer.shadowOpacity = 0.5
        self.contentView.layer.shadowOffset = CGSize(width: -2, height: 2)
        self.contentView.layer.shadowRadius = 2
        
        self.contentView.layer.shadowPath = UIBezierPath(rect: self.contentView.bounds).cgPath
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func pauseUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
        Timer.scheduledTimer(timeInterval: self.updateLocationTimeInterval, target: self, selector: #selector(startUpdatingLocation), userInfo: nil, repeats: false)

    }
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint:CGPoint = sender.location(in: self.mapView)
        let touchMapCoordinate:CLLocationCoordinate2D =
            self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        self.selectedLocation = touchMapCoordinate
        let annotation = PlaceAnnotationView(lat: touchMapCoordinate.latitude, long: touchMapCoordinate.longitude)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        self.centerMap(touchMapCoordinate)
        pauseUpdatingLocation()
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onShareButtonPressed(_ sender: Any) {
        completion?(self.selectedLocation)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
