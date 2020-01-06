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
    
	private var trackers: [Tracker]? {
		didSet {
			if trackers?.count ?? 0 > 0 {
				self.tableView.removeNoDataPlaceholder()
			} else {
				self.tableView.setNoDataPlaceholder("No available trackers")
			}
		}
	}
    private var selectedTracker: Tracker?
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        self.navigationItem.leftBarButtonItem = self.editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addButtonTap(_:)))
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
	
	@objc func addButtonTap(_ sender: Any?) {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let newTrackerAction = UIAlertAction(title: "New tracker", style: .default, handler: { _ in
			self.tabBarController?.selectedIndex = 0
		})
		
		let importAction = UIAlertAction(title: "Import", style: .default, handler: { _ in
			let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.topografix.gpx"],
																in: .import)
			documentPicker.delegate = self
			
			self.present(documentPicker, animated: true)
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		actionSheet.addAction(newTrackerAction)
		actionSheet.addAction(importAction)
		actionSheet.addAction(cancelAction)

		if let presentation = actionSheet.popoverPresentationController {
			presentation.barButtonItem = self.navigationItem.rightBarButtonItem
		}
		
		self.present(actionSheet, animated: true)
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

// MARK: - UIDocumentPickerDelegate methods

extension TrackerListViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		do {
			let /*points*/ _ = try GPXParseManager.parseGPX(fromUrl: url, save: true)
//			print(points)
		} catch {
			print(error)
		}
	}
}
