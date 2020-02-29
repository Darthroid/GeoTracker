//
//  TrackerListViewModel.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import GeoTrackerCore

/// ViewModel representing tracker list screen
class TrackerListViewModel {
	private(set) var trackers: Dynamic<[TrackerViewModel]> = Dynamic([])

	public init() {
		self.subscribeForDbEvents()
		self.fetchTrackers()
	}

	public func subscribeForDbEvents() {
		CoreDataManager.shared.addObserver(self)
	}

	public func fetchTrackers() {
		print(#function)
		do {
			let trackers = try CoreDataManager.shared.fetchTrackers()
			let trackerViewModels = trackers.map({ TrackerViewModel(from: $0) })
			self.trackers = Dynamic(trackerViewModels)
		} catch {
			assert(false, error.localizedDescription)
		}
	}

	public func deleteTracker(_ tracker: TrackerViewModel) throws {
		do {
			try CoreDataManager.shared.deleteTrackers(withId: tracker.id)
		} catch {
			throw error
		}
	}

	public func parseGpxFrom(_ url: URL) throws {
		do {
			let parseResult = try GPXParseManager.parseGPX(fromUrl: url)
			try CoreDataManager.shared.insertTracker(withId: parseResult.id,
													 name: parseResult.name,
													 points: parseResult.points)
		} catch {
			throw(error)
		}
	}
}

// MARK: - CoreDataObserver methods

extension TrackerListViewModel: CoreDataObserver {
	func didInsert(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			self.trackers.value.append(TrackerViewModel(from: tracker))
		})
	}

	func didUpdate(ids: [String], trackers: [Tracker]?) {
		//
	}

	func didDelete(ids: [String], trackers: [Tracker]?) {
		if let trackers = trackers {
			trackers.forEach({ tracker in
				self.trackers.value.removeAll(where: { $0.id == tracker.id })
			})
		} else {
			ids.forEach({ id in
				self.trackers.value.removeAll(where: { $0.id == id })
			})
		}
	}
}
