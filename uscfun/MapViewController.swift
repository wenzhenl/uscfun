//
//  MapViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var placename: String!
    var placemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "地图"
        let navigationImage = #imageLiteral(resourceName: "navigation").scaleTo(width: 22, height: 22)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: navigationImage, style: .plain, target: self, action: #selector(route))
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = placename
        mapView.addAnnotation(annotation)
        placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
    }
    
    func route() {
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placename
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
