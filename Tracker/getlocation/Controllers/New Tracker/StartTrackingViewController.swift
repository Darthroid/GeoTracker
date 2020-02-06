//
//  StartTrackingViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StartTrackingViewController: UIViewController {
	// MARK: - Outlets
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var statusTextView: UITextView!
	@IBOutlet weak var finishTrackingButton: UIButton!
	
	// MARK: - Public properties
	
	public var viewModel: TrackerRecorderViewModel?
	
	// MARK: - ViewController lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		mapView.showsUserLocation = true
		self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
		
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
	
	private func observeLocationUpdates() {
		viewModel?.locationUpdateHandler = { [weak self] updateType in
			guard let `self` = self else { return }
			
			switch updateType {
			case .timerUpdate:
				self.mapView.removeOverlays(self.mapView.overlays)
				self.mapView.addOverlay(self.polyLine())
			case .locationUpdate:
				self.statusTextView.text = self.viewModel?.locationInfoString
			}
		}
	}
	
	// MARK: - Actions
	
	@IBAction func finishTracking(_ sender: Any) {
		viewModel?.stopRecording()
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - MKMapViewDelegate methods

extension StartTrackingViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = .blue
		renderer.lineWidth = 4
		return renderer
	}
	
	private func polyLine() -> MKPolyline {
		let coordinates = viewModel?.storedCoordinates ?? []
		return MKPolyline(coordinates: coordinates, count: coordinates.count)
	}
}
