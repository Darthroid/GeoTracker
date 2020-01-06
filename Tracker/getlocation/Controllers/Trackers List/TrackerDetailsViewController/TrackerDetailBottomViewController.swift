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
}

class TrackerDetailBottomViewController: UIViewController {
	
    // MARK: - Outlets & connections
	
	@IBOutlet weak var trackerNameLabel: UILabel!
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

}

// MARK: - UITableViewDelegate methods

extension TrackerDetailBottomViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.points.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PointCell", for: indexPath)
		let point = self.points[indexPath.row]
		
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd hh:mm:ss"
		let date = Date(timeIntervalSince1970: TimeInterval(point.timestamp))
		let dateString = df.string(from: date)
		
		cell.textLabel?.text = dateString
		cell.detailTextLabel?.text = "Latitude: \(point.latitude)" + "\n" + "Longitude: \(point.longitude)"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate?.didSelectPoint(points[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
