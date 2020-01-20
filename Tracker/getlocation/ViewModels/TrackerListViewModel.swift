//
//  TrackerListViewModel.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class TrackerListViewModel {
	var dataSource = TrackerListDataSource()
	
	public init() {
		
	}
	
	public func subscribeForDatabase() {
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
}

extension TrackerListViewModel: CoreDataObserver {
	func didInsert(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			self.dataSource.data.value.append(TrackerViewModel(from: tracker))
		})
	}
	
	func didUpdate(ids: [String], trackers: [Tracker]) {
		// TODO:
	}
	
	func didDelete(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			self.dataSource.data.value.removeAll(where: { $0.id == tracker.id })
		})
	}
}

class TrackerListDataSource: GenericDataSource<TrackerViewModel>, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		assert(false, "implement cell configuration")
		return UITableViewCell()
	}
}
