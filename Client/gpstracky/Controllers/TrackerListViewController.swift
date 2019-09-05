//
//  TrackerListViewController.swift
//  gpstracky
//
//  Created by Oleg Komaristy on 04.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit

protocol TrackerSelectionDelegate: class {
    func trackerSelected(_ tracker: Tracker)
}

class TrackerListViewController: UITableViewController {
    
    private var trackers: [String: [TrackerPoint]] = [:]
    private var selectedTracker: Tracker?
    
    fileprivate var collapseDetailViewController = true
    
    weak var delegate: TrackerSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
        self.configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchTrackersList()
    }
    
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Reload")
        refreshControl.addTarget(self, action: #selector(refreshControlDidDragged(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func refreshControlDidDragged(_ sender: UIRefreshControl) {
        self.fetchTrackersList()
    }
    
    private func fetchTrackersList() {
        NetworkManager.fetchTrackers(completion: { [weak self] fetchedTrackers in
            self?.refreshControl?.endRefreshing()
            if let fetchedTrackers = fetchedTrackers {
                self?.trackers = fetchedTrackers
                self?.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackerCell", for: indexPath)
        cell.textLabel?.text = trackers.map({$0.key})[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTracker = trackers.map({$0.value})[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        collapseDetailViewController = false
        guard let navController = segue.destination as? UINavigationController,
            let viewController = navController.topViewController as? TrackerDetailViewController else {
                fatalError("Expected DetailViewController")
        }
        
        // Manage the display mode button
        viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        viewController.navigationItem.leftItemsSupplementBackButton = true
        
        // Configure the secondary view controller
        viewController.tracker = selectedTracker
    }
    
}

extension TrackerListViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}
