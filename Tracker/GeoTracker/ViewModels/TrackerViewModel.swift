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

	var points: Dynamic<[PointViewModel]> {
		let points = Array(tracker.points ?? Set())
		return Dynamic(points.map({ PointViewModel(from: $0) }))
	}

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

extension TrackerViewModel: Comparable {
	static func < (lhs: TrackerViewModel, rhs: TrackerViewModel) -> Bool {
		fatalError("not implemented")
	}

	static func == (lhs: TrackerViewModel, rhs: TrackerViewModel) -> Bool {
		return lhs.id == rhs.id
	}
}
