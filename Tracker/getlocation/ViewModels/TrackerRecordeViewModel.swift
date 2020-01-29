//
//  TrackerRecordeViewModel.swift
//  getlocation
//
//  Created by Oleg Komaristy on 27.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

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
	
	public init() {
		//
	}
	
	public func startRecording() {
		
	}
	
	public func stopRecording() {
		
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
