//
//  SearchResultsTableViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/13/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

protocol SearchResultDelegate {
    func didSelectedAddress(place: MKMapItem?)
}

class SearchResultsTableViewController: UITableViewController {

    var matchingItems = [MKMapItem]()
    
    var delegate: SearchResultDelegate?
    
    var region: MKCoordinateRegion?
    
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.backgroundGray
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = searchText
        } else {
            let selectedItem = matchingItems[indexPath.row - 1].placemark
            cell.textLabel?.text = selectedItem.name
            cell.detailTextLabel?.text = SearchResultsTableViewController.parseAddress(selectedItem: selectedItem)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.didSelectedAddress(place: nil)
        } else {
            delegate?.didSelectedAddress(place: matchingItems[indexPath.row - 1])
        }
    }
    
    static func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? "",
            " ",
            // zipcode
            selectedItem.postalCode ?? ""
            
        )
        return addressLine
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        self.searchText = searchBarText
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        if region != nil {
            request.region = self.region!
        }
        let search = MKLocalSearch(request: request)
        search.start {
            response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
