//
//  TrackerRecordeViewModel.swift
//  getlocation
//
//  Created by Oleg Komaristy on 27.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreLocation

class TrackerRecorderViewModel {
	
	public let updateFrequencyOptions: [(time: String, value: Double)] = [("5 seconds",   5.0),
																		  ("10 seconds",  10.0),
																		  ("30 seconds",  30.0),
																		  ("1 minute",    60.0),
																		  ("5 minutes",   60.0 * 5),
																		  ("10 minutes",  60.0 * 10),
																		  ("30 minutes",  60.0 * 30),
																		  ("1 hour",      60.0 * 60)]
	private var points = [Point]()
	
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
	
	public var eventHandler: () -> Void = {}
	
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
}

extension TrackerRecorderViewModel: TrackerRecordManagerDelegate {
	func trackerRecordingDidStart() {
		// prepare for location updates
	}
	
	func trackerRecordingDidPaused() {
		// TODO: pause
	}
	
	func trackerRecordingDidFinished() {
		// do something with controller updates
		try? self.saveTrackerData()
		points.removeAll()
	}
	
	func trackerRecordingDidUpdateLocation(_ location: CLLocation) {
		let point = Point()
		point.id = UUID().uuidString
		point.latitude = location.coordinate.latitude
		point.longitude = location.coordinate.longitude
		point.timestamp = Int64(Date().timeIntervalSince1970)
		
		self.points.append(point)
		self.eventHandler()
	}
}
