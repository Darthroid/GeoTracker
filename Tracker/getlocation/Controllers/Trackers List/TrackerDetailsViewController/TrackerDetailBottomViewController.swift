//
//  TrackerDetailBottomViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import UIKit

protocol TrackerDetailBottomDelegate: class {
	func didSelectPoint(_ point: TrackerPoint)
//	func didRequestSnapshot() -> Data?
}

class TrackerDetailBottomViewController: UIViewController {
	
    // MARK: - Outlets & connections
	
	@IBOutlet weak var trackerNameLabel: UILabel!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
    // MARK: - Public properties
	
	public weak var delegate: TrackerDetailBottomDelegate?
	public var tracker: Tracker? {
		didSet {
			self.points = tracker?.points?.map({ TrackerPoint(latitude: $0.latitude,
															  longitude: $0.longitude,
															  id: $0.id,
															  timestamp: $0.timestamp) }) ?? []
		}
	}
	
	// MARK: - Private properties
	
	private var points: [TrackerPoint] = []

    // MARK: - ViewController LifeCycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setupInterface()
	}
	
    // MARK: - User defined methods
	
	private func setupInterface() {
		self.trackerNameLabel.text = tracker?.name ?? ""
	}
	
	private func presentShareSheet(with itemsToShare: [Any], sender: Any) {
		let activityViewController = UIActivityViewController(activityItems: itemsToShare,
															  applicationActivities: [])
		
		activityViewController.popoverPresentationController?.sourceView = sender as? UIView

		self.present(activityViewController, animated: true, completion: nil)
	}
	
	// MARK: - Actions
	
	@IBAction func shareTap(_ sender: Any) {
//		let actionSheet = UIAlertController(title: "Export options", message: nil, preferredStyle: .actionSheet)
//
//		let snapshotAction = UIAlertAction(title: "Map snapshot", style: .default, handler: { _ in
//			guard let snapshot = self.delegate?.didRequestSnapshot() else { return }
//			self.presentShareSheet(with: [snapshot], sender: sender)
//		})
		
//		let gpxAction = UIAlertAction(title: "GPS Exchange Format (GPX)", style: .default, handler: { _ in
		guard let tracker = self.tracker else { return }
		GPXParseManager.createGPX(fromTracker: tracker, save: true, completionHandler: { gpxString, fileUrl in
			DispatchQueue.main.async {
				if let fileUrl = fileUrl {
					self.presentShareSheet(with: [fileUrl], sender: sender)
				} else {
					self.presentShareSheet(with: [gpxString], sender: sender)
				}
			}
		})
//		})
		
//		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//		actionSheet.addAction(snapshotAction)
//		actionSheet.addAction(gpxAction)
//		actionSheet.addAction(cancelAction)
//		actionSheet.popoverPresentationController?.sourceView = sender as? UIView
//
//		self.present(actionSheet, animated: true)
	}
	
}

// MARK: - UITableViewDelegate methods

extension TrackerDetailBottomViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.points.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PointCell", for: indexPath)
		let point = self.points[indexPath.row]

		cell.textLabel?.text = Date().stringfromTimeStamp(point.timestamp)
		cell.detailTextLabel?.text = "Latitude: \(point.latitude)" + "\n" + "Longitude: \(point.longitude)"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate?.didSelectPoint(points[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
