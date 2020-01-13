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
	private var collapseDetailViewController = true
    
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
		
		self.fetchTrackers()
		
		CoreDataManager.shared.addObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
		self.setupInterface()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TrackerDetailViewController {
            viewController.tracker = selectedTracker
			viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
			viewController.navigationItem.leftItemsSupplementBackButton = true
        }
		
        collapseDetailViewController = false
//        guard let navController = segue.destination as? UINavigationController,
//            let viewController = navController.topViewController as? TrackerDetailViewController else {
//                fatalError("Expected DetailViewController")
//        }
        
        // Manage the display mode button

        
        // Configure the secondary view controller
//        viewController.tracker = selectedTracker
    }
	
	deinit {
		CoreDataManager.shared.removeObserver(self)
	}
    
    // MARK: - User defined methods
    
	private func setupInterface() {
		let interfaceIdiom = UIDevice.current.userInterfaceIdiom
		self.tableView.separatorStyle = interfaceIdiom == .phone ? .none : .singleLine
	}
	
    private func fetchTrackers() {
        do {
            self.trackers = try CoreDataManager.shared.fetchTrackers()
//            self.tableView.reloadData()
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
		return UIDevice.current.userInterfaceIdiom == .phone ? 300 : UITableView.automaticDimension
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let tracker = self.trackers?[indexPath.row] else {
			assert(false)
			return UITableViewCell()
		}
		
		if UIDevice.current.userInterfaceIdiom == .phone {	// cell with route preview
			let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackerCell.self),
													 for: indexPath) as! TrackerCell
			cell.configure(with: tracker)
			return cell
		} else {	// default title/subtitle cell
			let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCellSimple", for: indexPath)
			cell.textLabel?.text = tracker.name
			cell.detailTextLabel?.text = "\(String(describing: tracker.points?.count ?? 0)) points"
			return cell
		}
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
			AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
		}
	}
}

// MARK: - UISplitViewControllerDelegate methods

extension TrackerListViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}

// MARK: - CoreDataObserver methods

extension TrackerListViewController: CoreDataObserver {
	func didInsert(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ self.trackers?.append($0) })
		
		DispatchQueue.main.async {
			self.tableView.beginUpdates()
			self.tableView.insertRows(at: [IndexPath(row: (self.trackers?.count ?? 1) - 1, section: 0)], with: .automatic)
			self.tableView.endUpdates()
		}
	}
	
	func didUpdate(ids: [String], trackers: [Tracker]) {
//		trackers.forEach({ tracker in
//
//		})
	}
	
	func didDelete(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			guard let index = self.trackers?.firstIndex(of: tracker) else { return }
			self.trackers?.remove(at: index)
			
			DispatchQueue.main.async {
				self.tableView.beginUpdates()
				self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
				self.tableView.endUpdates()
			}
		})
	}

}
