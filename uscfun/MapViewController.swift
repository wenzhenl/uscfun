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
    let latitude = 34.0090
    let longitude = -118.4974
    var placemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "地图"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(route))
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        let place = CLLocationCoordinate2DMake(latitude, longitude)
        placemark = MKPlacemark(coordinate: place, addressDictionary: nil)
    }
    
    func route() {
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate
            annotation.title = placemark.name
            if let city = placemark.locality, let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
                print(city)
                print(state)
            }
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:\(error)")
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("annotation view")
        if annotation is MKUserLocation {
            print("nil returned")
            return nil
        }
        let reusedId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
        if #available(iOS 9.0, *) {
            pinView?.pinTintColor = UIColor.orange
        } else {
            // Fallback on earlier versions
        }
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "car"), for: .normal)
        button.addTarget(self, action: #selector(route), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
