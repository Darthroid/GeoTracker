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
}

class TrackerRecordManager {
	public static var shared = TrackerRecordManager()
	
	weak var timer: Timer?
	weak var delegate: TrackerRecordManagerDelegate?
}
