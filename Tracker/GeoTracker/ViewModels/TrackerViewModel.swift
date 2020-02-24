//
//  TrackerViewModel.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import GeoTrackerCore

/// ViewModel representing tracker entity
class TrackerViewModel: RowViewModel {
	private var tracker: Tracker
	
	private(set) var points: Dynamic<[PointViewModel]> = Dynamic([])
	
	public var name: String {
		return tracker.name ?? ""
	}
	
	public var description: String {
		"\(String(describing: tracker.points?.count ?? 0)) points"
	}
	
	public var id: String {
		return tracker.id
	}
		
	public init(from tracker: Tracker) {
		self.tracker = tracker
		let points = Array(tracker.points ?? Set())
		self.points = Dynamic(points.map({ PointViewModel(from: $0) }))
	}
}

extension TrackerViewModel {
	public func exportAsGPX(save: Bool = true, completionHandler: @escaping (String, URL?) -> Void) {
		GPXParseManager.createGPX(fromTracker: self.tracker, save: save, completionHandler: { gpxString, fileUrl in
			DispatchQueue.main.async {
				completionHandler(gpxString, fileUrl)
			}
		})
	}
}
