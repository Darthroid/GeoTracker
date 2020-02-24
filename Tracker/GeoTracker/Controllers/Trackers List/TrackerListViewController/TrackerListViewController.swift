//
//  TrackerListViewController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 22.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit

class TrackerListViewController: UITableViewController, Storyboarded {

    // MARK: - private properties

	private var dataSource: GenericDataSource<TrackerViewModel>?
	
	// MARK: - public properties
	
	public var viewModel: TrackerListViewModel!
	public var coordinator: TrackerListCoordinator?
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.tableView.delegate = self
		self.setupInterface()
		self.setupDataSource()
		self.setupBinding()
    }
    
    // MARK: - User defined methods
    
	private func setupInterface() {
		let interfaceIdiom = UIDevice.current.userInterfaceIdiom
		self.tableView.separatorStyle = interfaceIdiom == .phone ? .none : .singleLine
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addButtonTap(_:)))
	}
	
	private func setupDataSource() {
		let dataSource = GenericDataSource(
			models: viewModel.trackers,
			isEditable: true,
			reuseIdentifier: "TrackerCellSimple",
			cellConfigurator: { (trackerViewModel, cell) in
				if let cell = cell as? CellConfigurable {
					cell.setup(viewModel: trackerViewModel)
				}
			},
			eventHandler: { [weak self] (event, eventViewModel) in
				switch event {
				case .insert:
					break
				case .delete:
					try? self?.viewModel.deleteTracker(eventViewModel)
				}
			}
		)
		
		self.dataSource = dataSource
		tableView.dataSource = self.dataSource
	}
	
	private func setupBinding() {
		self.dataSource?.models.addAndNotify(observer: self) { [weak self] in
			guard let `self` = self else { return }
			print(self, "dataSource changed")
			// TODO: move placeholder handling somewhere else
			if self.dataSource?.models.value.count ?? 0 > 0 {
				self.tableView.removeNoDataPlaceholder()
			} else {
				self.tableView.setNoDataPlaceholder("No available trackers")
			}
			
			self.tableView.reloadData()
		}
	}
	
	@objc func addButtonTap(_ sender: Any?) {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let newTrackerAction = UIAlertAction(title: "New tracker", style: .default, handler: { _ in
			self.coordinator?.presenTrackerRecorder()
		})
		
		let importAction = UIAlertAction(title: "Import", style: .default, handler: { _ in
			let documentPicker = UIDocumentPickerViewController(documentTypes: DOC_TYPES,
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
		if let selectedViewModel = self.dataSource?.models.value[indexPath.row] {
			coordinator?.showDetail(with: selectedViewModel)
		}
    }
}

// MARK: - UIDocumentPickerDelegate methods

extension TrackerListViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		let fileName = (url.lastPathComponent as NSString).deletingPathExtension
		let ac = UIAlertController(title: "Import \(fileName) ?", message: "", preferredStyle: .alert)
		
		let importAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
			do {
				try self.viewModel.parseGpxFrom(url)
			} catch {
				AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
			}
		})
		
		let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
		
		ac.addAction(importAction)
		ac.addAction(cancelAction)
		
		self.present(ac, animated: true)
	}
}
