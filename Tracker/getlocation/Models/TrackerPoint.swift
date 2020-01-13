//
//  TrackerData.swift
//  getlocation
//
//  Created by Олег Комаристый on 02.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation

class TrackerPoint: CustomStringConvertible {
	var description: String {
		let properties = [
			"id": id,
			"latitude": latitude,
			"longitude": longitude,
			"timestamp": timestamp
		] as [String: Any]
		
		return "<\(TrackerPoint.self): \(properties)>\n"
	}
	
    var latitude: Double
    var longitude: Double
    var id: String
    var timestamp: Int64
    
    public init(latitude: Double, longitude: Double, id: String, timestamp: Int64) {
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        self.timestamp = timestamp
    }
	
	public func toCLLocationCoordinates() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
}
