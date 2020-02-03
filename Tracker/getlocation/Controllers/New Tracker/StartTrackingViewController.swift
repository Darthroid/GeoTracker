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
		
		viewModel?.startRecording()
		
		viewModel?.eventHandler = { [weak self] in
			guard let `self` = self else { return }
			
			self.mapView.setRegion(self.mapRegion(), animated: true)
			self.mapView.removeOverlays(self.mapView.overlays)
			self.mapView.addOverlay(self.polyLine())
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		viewModel?.stopRecording()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel?.stopRecording()
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
	
	private func mapRegion() -> MKCoordinateRegion {
		let lastCoordinate = self.mapView.userLocation.coordinate
		let startCoordinate = viewModel?.storedCoordinates.first ?? lastCoordinate
		
		let center = CLLocationCoordinate2D(latitude: (startCoordinate.latitude + lastCoordinate.latitude) / 2,
											longitude: (startCoordinate.longitude + lastCoordinate.longitude) / 2)
		
		let span = MKCoordinateSpan(latitudeDelta: abs(lastCoordinate.latitude - startCoordinate.latitude) * 1.3,
									longitudeDelta: abs(lastCoordinate.longitude - startCoordinate.longitude) * 1.3)
		
		return MKCoordinateRegion(center: center, span: span)
	}
	
	private func polyLine() -> MKPolyline {
		let coordinates = viewModel?.storedCoordinates ?? []
		return MKPolyline(coordinates: coordinates, count: coordinates.count)
	}
}
