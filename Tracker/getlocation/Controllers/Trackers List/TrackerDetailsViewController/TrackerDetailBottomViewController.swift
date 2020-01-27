//
//  TrackerDetailBottomViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import UIKit

protocol TrackerDetailBottomDelegate: class {
	func didSelectPoint(_ point: PointViewModel)
//	func didRequestSnapshot() -> Data?
}

class TrackerDetailBottomViewController: UIViewController {
	
    // MARK: - Outlets & connections
	
	@IBOutlet weak var trackerNameLabel: UILabel!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
    // MARK: - Public properties
	
	public weak var delegate: TrackerDetailBottomDelegate?
	
	public var viewModel: TrackerViewModel?


    // MARK: - ViewController LifeCycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = viewModel?.dataSource
		
		viewModel?.dataSource.data
			.addAndNotify(observer: self) { [weak self] in
				guard let `self` = self else { return }
				print(self, "dataSource changed")
				self.tableView.reloadData()
			}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setupInterface()
	}
	
    // MARK: - User defined methods
	
	private func setupInterface() {
		self.trackerNameLabel.text = viewModel?.name
	}
	
	private func presentShareSheet(with itemsToShare: [Any], sender: Any) {
		let activityViewController = UIActivityViewController(activityItems: itemsToShare,
															  applicationActivities: [])
		
		activityViewController.popoverPresentationController?.sourceView = sender as? UIView

		self.present(activityViewController, animated: true, completion: nil)
	}
	
	// MARK: - Actions
	
	@IBAction func shareTap(_ sender: Any) {
		self.viewModel?.exportAsGPX() { [weak self] gpxString, fileUrl in
			assert(Thread.isMainThread)
			if let fileUrl = fileUrl {
				self?.presentShareSheet(with: [fileUrl], sender: sender)
			} else {
				self?.presentShareSheet(with: [gpxString], sender: sender)
			}
		}
	}
}

// MARK: - UITableViewDelegate methods

extension TrackerDetailBottomViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let pointModel = viewModel?.dataSource.data.value[indexPath.row] else { return }
		delegate?.didSelectPoint(pointModel)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
