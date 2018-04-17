//
//  LocationChatMessageCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 14.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import MapKit

class LocationChatMessageCollectionViewCell: UICollectionViewCell, ChatCell {

    static let identifier = "LocationChatMessageCollectionViewCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageStatusImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    var location: CLLocationCoordinate2D?
    
    weak var delegate: LocationMessageDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setLocation(lat: Double, long: Double) {
        self.location = CLLocationCoordinate2DMake(lat, long)
    
        let annotation = PlaceAnnotationView(lat: lat, long: long)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        let newRegion = MKCoordinateRegion(center:CLLocationCoordinate2DMake(lat, long) , span: MKCoordinateSpanMake(Constants.Map.defaultLatitudeDelta, Constants.Map.defaultLongitudeDelta))
        self.mapView.setRegion(newRegion, animated: false)
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        return calculateHeight()
    }
    
    static func calculateHeight() -> CGFloat {
        return 250.0
    }
    
    @IBAction func onMapButtonPressed(_ sender: Any) {
        if let location = self.location {
            delegate?.onMapPressed(location)
        }
    }
    
}
