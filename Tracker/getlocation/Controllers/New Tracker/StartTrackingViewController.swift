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
import CoreData

class StartTrackingViewController: UIViewController {
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var statusTextView: UITextView!
	@IBOutlet weak var finishTrackingButton: UIButton!
	
	public var viewModel: TrackerRecorderViewModel?
	
	weak var timer: Timer?
	
	private var points = [Point]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		mapView.showsUserLocation = true
		LocationManager.shared.delegate = self
		LocationManager.shared.desiredAccuracy = kCLLocationAccuracyHundredMeters   //TODO: put that into settings
		
		self.startFetchingLocation()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopFetchingLocation()
	}
	
	private func observeTrackerData() {
		guard let viewModel = self.viewModel else { return }
		let authorizationStatus = CLLocationManager.authorizationStatus()
		guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else { return }
		timer = Timer.scheduledTimer(withTimeInterval: viewModel.trackerUpdateFrequency, repeats: true) { [unowned self] _ in
			if  let latitude = LocationManager.shared.location?.coordinate.latitude,
				let longitude = LocationManager.shared.location?.coordinate.longitude
			{
				let point = Point()
				point.latitude = latitude
				point.longitude = longitude
				point.id = UUID().uuidString
				point.timestamp = Int64(NSDate().timeIntervalSince1970)
				
				self.points.append(point)
				print(point.latitude, point.longitude, point.id)
			}
		}
	}
	
	private func startFetchingLocation() {
		timer?.invalidate()
		LocationManager.shared.startUpdatingLocation()
		LocationManager.shared.startMonitoringSignificantLocationChanges()
		
		self.observeTrackerData()
	}
	
	private func stopFetchingLocation() {
		timer?.invalidate()
		LocationManager.shared.stopUpdatingLocation()
		LocationManager.shared.stopMonitoringSignificantLocationChanges()
		LocationManager.shared.delegate = nil
	}
	
	@IBAction func finishTracking(_ sender: Any) {
		do {
			try viewModel?.saveTrackerData()
		} catch {
			AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
		}
		
		// TODO: waint until save operation is finished and then dismiss
		
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension StartTrackingViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = manager.location else { return }
		statusTextView.text = "Latitude: "    + String(describing: location.coordinate.latitude)
			+ "\nLongitude: " + String(describing: location.coordinate.latitude)
			+ "\nSpeed: "     + String(describing: location.speed)
		
		if let mapRegion = self.mapRegion() {
			mapView.setRegion(mapRegion, animated: true)
		} else {
			mapView.setCenter(location.coordinate, animated: true)
		}
		mapView.removeOverlays(mapView.overlays)
		mapView.addOverlay(polyLine())
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .denied, .notDetermined, .restricted:
			self.stopFetchingLocation()
		case .authorizedAlways, .authorizedWhenInUse:
			self.startFetchingLocation()
		@unknown default:
			self.stopFetchingLocation()
		}
	}
}

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
	
	private func mapRegion() -> MKCoordinateRegion? {
		let lastLocation = LocationManager.shared.location?.coordinate
		
		guard   let maxLat = lastLocation?.latitude,
			let minLat = points.first?.latitude,
			let maxLong = lastLocation?.longitude,
			let minLong = points.first?.longitude
			else { return nil }
		
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
											longitude: (minLong + maxLong) / 2)
		let span = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) * 1.3,
									longitudeDelta: abs(maxLong - minLong) * 1.3)
		return MKCoordinateRegion(center: center, span: span)
	}
	
	private func polyLine() -> MKPolyline {
		let coords: [CLLocationCoordinate2D] = points.map { point in
			return CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
		}
		return MKPolyline(coordinates: coords, count: coords.count)
	}
}
