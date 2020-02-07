//
//  TrackerRecordManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 29.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol TrackerRecordManagerDelegate: class {
	func trackerRecordingDidStart()
	func trackerRecordingDidPaused()
	func trackerRecordingDidFinished()
	func trackerRecordingDidTick(_ location: CLLocation)
	func trackerRecordingDidUpdateLocation(_ location: CLLocation)
}

class TrackerRecordManager: NSObject {
	public static var shared = TrackerRecordManager()
	
	weak var timer: Timer?
	weak var delegate: TrackerRecordManagerDelegate?
	
	public var updateFrequency: Double?
	
	override init() {
		super.init()
		
		LocationManager.shared.delegate = self
		LocationManager.shared.desiredAccuracy = kCLLocationAccuracyHundredMeters   //TODO: put that into settings
	}
	
	deinit {
		timer?.invalidate()
		timer = nil
		LocationManager.shared.delegate = nil
	}
	
	public func start() {
		guard let updateFrequency = self.updateFrequency, updateFrequency > 0 && !updateFrequency.isNaN else {
			assertionFailure("invalid updateFrequency")
			return
		}
		LocationManager.shared.startUpdatingLocation()
		LocationManager.shared.startMonitoringSignificantLocationChanges()
		
		delegate?.trackerRecordingDidStart()
		
		timer = Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { [weak self] _ in
			self?.timerUpdate()
		}
	}
	
	public func pause() {
		// TODO: pause recording
		delegate?.trackerRecordingDidPaused()
	}
	
	public func stop() {
		timer?.invalidate()
		LocationManager.shared.stopUpdatingLocation()
		LocationManager.shared.stopMonitoringSignificantLocationChanges()
		
		delegate?.trackerRecordingDidFinished()
	}
	
	private func timerUpdate() {
		guard let location = LocationManager.shared.location else { return }
		let latitude = location.coordinate.latitude
		let longitude = location.coordinate.longitude
		
		print(self, #function, "lat: \(latitude); lon: \(longitude)")
		self.delegate?.trackerRecordingDidTick(location)
	}
}

extension TrackerRecordManager: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		delegate?.trackerRecordingDidUpdateLocation(location)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .denied, .notDetermined, .restricted:
			self.pause()
		case .authorizedAlways, .authorizedWhenInUse:
//			self.start()
			break
		@unknown default:
			self.stop()
		}
	}
}
