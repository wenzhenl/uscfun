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
    
    lazy var tableView: UITableView = { [unowned self] in
        let v = UITableView(frame: self.view.bounds)
        return v
    }()
    
    var resultsSearchController: UISearchController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        resultsSearchController = UISearchController(searchResultsController: self)
        let searchBar = resultsSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultsSearchController!.searchBar
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension AddressPickerViewController: UITableViewDataSource, UITableViewDelegate{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "hhaaa"
        return cell
    }
}

extension AddressPickerViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
    }
}
