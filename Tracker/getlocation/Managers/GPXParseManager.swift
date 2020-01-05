//
//  GPXParseManager.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreGPX

class GPXParseManager {
	public class func parseGPX(fromUrl url: URL, save: Bool = false) throws -> [TrackerPoint] {
		guard url.startAccessingSecurityScopedResource(), let gpx = GPXParser(withURL: url)?.parsedData() else {
			throw NSError(domain: "Unable to parse gpx from path: \(url)", code: 1, userInfo: nil)
		}
		let trackerName = (url.lastPathComponent as NSString).deletingPathExtension
		
		url.stopAccessingSecurityScopedResource()
		return GPXParseManager.parse(trackerName, waypoints: gpx.waypoints, save: save)
	}
	
	private class func parse(_ name: String, waypoints: [GPXWaypoint], save: Bool = false) -> [TrackerPoint] {
		var trackerPoints: [TrackerPoint] = []
		let trackerId = UUID().uuidString
		
		waypoints.forEach({ waypoint in
			guard let latitude = waypoint.latitude, let longitude = waypoint.longitude else { return }
			let id = UUID().uuidString	// we need to generate uuid for every waypoint
			let convertedPoint = TrackerPoint(latitude: latitude,
											  longitude: longitude,
											  id: id,
											  timestamp: Int64(waypoint.time?.timeIntervalSince1970 ?? 0))
			trackerPoints.append(convertedPoint)
		})
		
		if save {
			do {
				try CoreDataManager.shared.insertTracker(withId: trackerId,
														 name: name,
														 points: trackerPoints)
			} catch {
				print(error)
			}
		}
		
		return trackerPoints
	}
}
