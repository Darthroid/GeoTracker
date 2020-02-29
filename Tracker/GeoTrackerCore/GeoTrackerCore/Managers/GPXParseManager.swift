//
//  GPXParseManager.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreGPX

public class GPXParseManager {
	public typealias ParseResult = (id: String, name: String, points: [TrackerPoint])

	public class func parseGPX(fromUrl url: URL) throws -> ParseResult {
		_ = url.startAccessingSecurityScopedResource()
		guard let gpx = GPXParser(withURL: url)?.parsedData() else {
			throw NSError(domain: "Unable to parse gpx from path: \(url)", code: 1, userInfo: nil)
		}
		let trackerName = (url.lastPathComponent as NSString).deletingPathExtension

		url.stopAccessingSecurityScopedResource()
		return GPXParseManager.parse(trackerName, waypoints: gpx.waypoints)
	}

	/// Creates gpx formatted string and optionally saves to documents directory
	/// - Parameters:
	///   - tracker: Tracker with points to be processed
	///   - save: Indicates whether tracker needs to be saved to file or not
	public class func createGPX(fromTracker tracker: Tracker, save: Bool = false, completionHandler: @escaping (String, URL?) -> Void) {
		DispatchQueue.global(qos: .userInitiated).async {
			let root = GPXRoot(creator: Bundle.main.displayName)
			var waypoints: [GPXWaypoint] = []

			tracker.points?.forEach({ point in
				let waypoint = GPXWaypoint(latitude: point.latitude, longitude: point.longitude)
				waypoints.append(waypoint)
			})

			root.add(waypoints: waypoints)

			let gpxString = root.gpx()

			if save {
				let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
				do {
					let date = Date()
					let dateString = date.stringfromTimeStamp(Int64(date.timeIntervalSince1970))

					let fileName = tracker.name ?? "Tracker_" + dateString

					try root.outputToFile(saveAt: url, fileName: fileName)
					completionHandler(gpxString, url.appendingPathComponent(fileName).appendingPathExtension("gpx"))
				} catch {
					completionHandler(gpxString, nil)
				}
			} else {
				completionHandler(gpxString, nil)
			}
		}
	}

	private class func parse(_ name: String, waypoints: [GPXWaypoint]) -> ParseResult {
		var trackerPoints: [TrackerPoint] = []
		let trackerId = UUID().uuidString

		waypoints.forEach({ waypoint in
			guard let latitude = waypoint.latitude, let longitude = waypoint.longitude else { return }
			let id = UUID().uuidString	// we need to generate uuid for every waypoint

			let convertedPoint = TrackerPoint()
			convertedPoint.latitude = latitude
			convertedPoint.longitude = longitude
			convertedPoint.id = id
			convertedPoint.timestamp = Int64(waypoint.time?.timeIntervalSince1970 ?? 0)

			trackerPoints.append(convertedPoint)
		})

		return (id: trackerId, name: name, points: trackerPoints)
	}
}
