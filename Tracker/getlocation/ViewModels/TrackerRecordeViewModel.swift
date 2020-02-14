//
//  TrackerRecordeViewModel.swift
//  getlocation
//
//  Created by Oleg Komaristy on 27.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreLocation
import GeoTrackerCore

class TrackerRecorderViewModel {
	enum TrackerRecordEvent {
		case timerUpdate
		case locationUpdate
	}
	
	public let updateFrequencyOptions: [(time: String, value: Double)] = [("5 seconds",   5.0),
																		  ("10 seconds",  10.0),
																		  ("30 seconds",  30.0),
																		  ("1 minute",    60.0),
																		  ("5 minutes",   60.0 * 5),
																		  ("10 minutes",  60.0 * 10),
																		  ("30 minutes",  60.0 * 30),
																		  ("1 hour",      60.0 * 60)]
	private var points = [TrackerPoint]()
	
	//  Coordinates used by StartTrackingViewController to draw polyLine
	public var storedCoordinates: [CLLocationCoordinate2D] {
		let coordinates = points.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
		return coordinates
	}
	
	public var trackerName: String = ""
	public var trackerUpdateFrequency: Double = 0.0
	
	public var isValidTrackerInfo: Bool {
		switch LocationManager.authorizationStatus() {
		case .notDetermined, .restricted, .denied:
			return false
		case .authorizedAlways, .authorizedWhenInUse:
			return !self.trackerName.isEmpty
				&& !self.trackerUpdateFrequency.isNaN
				&& self.trackerUpdateFrequency > 0
		@unknown default:
			return false
		}
	}
	
	public var locationInfoString: String {
		guard let location = LocationManager.shared.location else { return "" }
		return 	"Latitude: \(location.coordinate.latitude)" + "\n" +
				"Longitude: \(location.coordinate.longitude)" + "\n" +
				"Speed: \((location.speed * 3.6).rounded(.up)) km/h" + "\n" +
				"Alt: \(location.altitude) m"
	}
	
	public var locationUpdateHandler: (TrackerRecordEvent) -> Void = { _ in }
	
	public init() {
		TrackerRecordManager.shared.delegate = self
	}
	
	public func startRecording() {
		TrackerRecordManager.shared.updateFrequency = self.trackerUpdateFrequency
		TrackerRecordManager.shared.start()
	}
	
	public func stopRecording() {
		TrackerRecordManager.shared.stop()
	}
	
	public func saveTrackerData() throws {
		guard !points.isEmpty else { return }
		do {
			try CoreDataManager.shared.insertTracker(withId: UUID().uuidString,
													 name: self.trackerName,
													 points: self.points)
		} catch {
			throw(error)
		}
	}
	
	private func clean() {
		self.points.removeAll()
		self.trackerName = ""
		self.trackerUpdateFrequency = 0.0
	}
}

extension TrackerRecorderViewModel: TrackerRecordManagerDelegate {
	func trackerRecordingDidStart() {
		//
	}
	
	func trackerRecordingDidPaused() {
		// TODO: pause
	}
	
	func trackerRecordingDidFinished() {
		// do something with controller updates
		try? self.saveTrackerData()
		self.clean()
	}
	
	func trackerRecordingDidTick(_ location: CLLocation) {
		let point = TrackerPoint()
		point.id = UUID().uuidString
		point.latitude = location.coordinate.latitude
		point.longitude = location.coordinate.longitude
		point.timestamp = Int64(location.timestamp.timeIntervalSince1970) //Int64(Date().timeIntervalSince1970)
		
		self.points.append(point)
		self.locationUpdateHandler(.timerUpdate)
	}
	
	func trackerRecordingDidUpdateLocation(_ location: CLLocation) {
		self.locationUpdateHandler(.locationUpdate)
	}
}
