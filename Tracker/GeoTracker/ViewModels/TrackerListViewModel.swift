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
	var dataSource: TrackerListDataSource!
	
	public init() {
		self.subscribeForDbEvents()
		
		dataSource = TrackerListDataSource(eventHandler: { [weak self] event, eventViewModel in
			switch event {
			case .delete:
				try? self?.deleteTracker(eventViewModel)
			default:
				assert(false, "not implemented")
			}
		})
	}
	
	public func subscribeForDbEvents() {
		CoreDataManager.shared.addObserver(self)
	}
	
	public func fetchTrackers() {
		print(#function)
		do {
			let trackers = try CoreDataManager.shared.fetchTrackers()
			let _dataSource = trackers.map({ TrackerViewModel(from: $0) })
			self.dataSource.data.value = _dataSource
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
			try GPXParseManager.parseGPX(fromUrl: url, save: true)
		} catch {
			throw(error)
		}
	}
}

// MARK: - CoreDataObserver methods

extension TrackerListViewModel: CoreDataObserver {
	func didInsert(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			self.dataSource.data.value.append(TrackerViewModel(from: tracker))
		})
	}
	
	func didUpdate(ids: [String], trackers: [Tracker]?) {
		// TODO:
	}
	
	func didDelete(ids: [String], trackers: [Tracker]?) {
		if let trackers = trackers {
			trackers.forEach({ tracker in
				self.dataSource.data.value.removeAll(where: { $0.id == tracker.id })
			})
		} else {
			ids.forEach({ id in
				self.dataSource.data.value.removeAll(where: { $0.id == id })
			})
		}
	}
}
