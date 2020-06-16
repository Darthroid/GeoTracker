//
//  StartTrackingViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
//import MapKit
import CoreLocation

class StartTrackingViewController: UIViewController, Storyboarded {
	// MARK: - Outlets

//	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapContainerView: UIView!
	@IBOutlet weak var statusTextView: UITextView!
	@IBOutlet weak var finishTrackingButton: UIButton!

	// MARK: - Public properties

	public var viewModel: TrackerRecorderViewModel?
	public weak var coordinator: NewTrackerCoordinator?

	var mapController: MapViewController!

	// MARK: - ViewController lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()

		self.setupChildViewControllers()
		self.mapController.mapView.showsUserLocation = true
		self.mapController.mapView.setUserTrackingMode(.followWithHeading, animated: true)

		viewModel?.startRecording()
		self.observeLocationUpdates()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		viewModel?.stopRecording()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel?.stopRecording()
	}

	// MARK: - User defined methods

	private func setupChildViewControllers() {
		addChild(mapController)
		mapController.didMove(toParent: self)
		self.mapContainerView.addSubview(mapController.view)
		self.mapController.view.frame = self.mapContainerView.bounds
	}

	private func observeLocationUpdates() {
		viewModel?.locationUpdateHandler = { [weak self] updateType in
			guard let `self` = self else { return }

			switch updateType {
			case .timerUpdate:
				self.mapController.mapView.removeOverlays(self.mapController.mapView.overlays)
				self.mapController.drawPolyline(with: self.viewModel?.storedCoordinates ?? [], isNeedToCenter: false)
			case .locationUpdate:
				self.statusTextView.text = self.viewModel?.locationInfoString
			}
		}
	}

	// MARK: - Actions

	@IBAction func finishTracking(_ sender: Any) {
		viewModel?.stopRecording()
		coordinator?.finish()
	}
}
