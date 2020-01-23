//
//  TrackerViewModel.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

class TrackerViewModel: RowViewModel {
	private var tracker: Tracker
	
	public var points: [Point] {
		return Array(tracker.points ?? Set())
	}
	
	public var name: String {
		return tracker.name ?? ""
	}
	
	public var description: String {
		"\(String(describing: points.count)) points"
	}
	
	public var id: String {
		return tracker.id
	}
	
	public init(from tracker: Tracker) {
		self.tracker = tracker
	}
}
