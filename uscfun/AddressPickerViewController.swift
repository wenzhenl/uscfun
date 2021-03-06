//
//  AddressPickerViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/13/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import Eureka

public class AddressPickerViewController: UIViewController, TypedRowControllerType {

    /// The row that pushed or presented this controller
    public var row: RowOf<String>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    var resultsSearchController: UISearchController?
    
    let locationManager = CLLocationManager()
    
    var region: MKCoordinateRegion?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
            locationManager.startUpdatingLocation()
        }
        
        let locationSearchTable = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultTable") as! SearchResultsTableViewController
        locationSearchTable.delegate = self
        locationSearchTable.region = self.region
        
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultsSearchController?.searchResultsUpdater = locationSearchTable
        resultsSearchController?.delegate = self
        
        let searchBar = resultsSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "搜索地址"
        navigationItem.titleView = resultsSearchController!.searchBar
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.resultsSearchController?.isActive = true
    }
}

extension AddressPickerViewController: SearchResultDelegate {
    func didSelectedAddress(place: MKMapItem?) {
        guard let place = place else {
            row.value = self.resultsSearchController?.searchBar.text
            onDismissCallback?(self)
            return
        }
        row.value = place.name
        
        (row as? LocationAddressRow)?.latitude = place.placemark.location?.coordinate.latitude
        (row as? LocationAddressRow)?.longitude = place.placemark.location?.coordinate.longitude
        onDismissCallback?(self)
    }
}

extension AddressPickerViewController : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            self.region = MKCoordinateRegionMake(location.coordinate, span)
        }
    }
}

extension AddressPickerViewController: UISearchControllerDelegate {
    public func didPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in }) {
            completed in
            searchController.searchBar.becomeFirstResponder()
        }
    }
}
