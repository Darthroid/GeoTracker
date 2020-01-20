//
//  TrackerViewModel.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

class TrackerViewModel {
	private var tracker: Tracker
	
	public var points: [Point] {
		return Array(tracker.points ?? Set())	// TODO: deal with optionals
	}
	
	public var name: String {
		return tracker.name ?? ""
	}
	
	public var id: String {
		return tracker.id
	}
	
	public init(from tracker: Tracker) {
		self.tracker = tracker
	}
}
