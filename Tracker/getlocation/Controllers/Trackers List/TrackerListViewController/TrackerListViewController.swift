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

	private var collapseDetailViewController = true
	private var selectedViewModel: TrackerViewModel?
	
	public var viewModel = TrackerListViewModel()
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addButtonTap(_:)))
        self.tableView.delegate = self
		self.tableView.dataSource = viewModel.dataSource
		self.viewModel.fetchTrackers()
		
		viewModel.dataSource.data
			.addAndNotify(observer: self) { [weak self] in
				guard let `self` = self else { return }
				print(self, "dataSource changed")
				// TODO: move placeholder handling somewhere else
				if self.viewModel.dataSource.data.value.count > 0 {
					self.tableView.removeNoDataPlaceholder()
				} else {
					self.tableView.setNoDataPlaceholder("No available trackers")
				}
				
				self.tableView.reloadData()
			}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
		self.setupInterface()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let viewController = segue.destination as? TrackerDetailViewController {
//            viewController.tracker = selectedTracker
//			viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//			viewController.navigationItem.leftItemsSupplementBackButton = true
//        }
		
        collapseDetailViewController = false
        guard let navController = segue.destination as? UINavigationController
			, let viewController = navController.topViewController as? TrackerDetailViewController else {
                fatalError("Expected DetailViewController")
        }

//		guard let viewController = segue.destination as? TrackerDetailViewController else {
//			fatalError("Expected DetailViewController")
//		}
		viewController.viewModel = selectedViewModel
		viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		viewController.navigationItem.leftItemsSupplementBackButton = true
    }
    
    // MARK: - User defined methods
    
	private func setupInterface() {
		let interfaceIdiom = UIDevice.current.userInterfaceIdiom
		self.tableView.separatorStyle = interfaceIdiom == .phone ? .none : .singleLine
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return UIDevice.current.userInterfaceIdiom == .phone ? 300 : UITableView.automaticDimension
		return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.selectedTracker = trackers?[indexPath.row]
		self.selectedViewModel = self.viewModel.dataSource.data.value[indexPath.row]
        self.performSegue(withIdentifier: "trackerDetail", sender: self)
    }
}

// MARK: - UIDocumentPickerDelegate methods

extension TrackerListViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		let fileName = (url.lastPathComponent as NSString).deletingPathExtension
		let ac = UIAlertController(title: "Import \(fileName) ?", message: "", preferredStyle: .alert)
		
		let importAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
			self.viewModel.parseGpxFrom(url)
		})
		
		let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
		
		ac.addAction(importAction)
		ac.addAction(cancelAction)
		
		self.present(ac, animated: true)
	}
}

// MARK: - UISplitViewControllerDelegate methods

extension TrackerListViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}
