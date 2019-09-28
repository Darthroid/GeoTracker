//
//  TrackerListViewController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 22.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit

class TrackerListViewController: UITableViewController {

    // MARK: - private properties
    
    private var trackers: [Tracker]?
    private var selectedTracker: Tracker?
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchTrackers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TrackerDetailViewController {
            vc.tracker = selectedTracker
        }
    }
    
    // MARK: - User defined methods
    
    private func fetchTrackers() {
        do {
            self.trackers = try CoreDataManager.shared.fetchTrackers()
            self.tableView.reloadData()
        } catch {
            AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDelegate methods

extension TrackerListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackers?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackerCell.self), for: indexPath) as! TrackerCell
        if let tracker = self.trackers?[indexPath.row] {
            cell.configure(with: tracker)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedTracker = trackers?[indexPath.row]
        self.performSegue(withIdentifier: "trackerDetail", sender: self)
        // pass tracker to detail viewcontroller
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let tracker = trackers?[indexPath.row] {
            do {
                try CoreDataManager.shared.delete(tracker: tracker)
                trackers?.removeAll(where: { tracker.id == $0.id })
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
            }
        }
    }
}
