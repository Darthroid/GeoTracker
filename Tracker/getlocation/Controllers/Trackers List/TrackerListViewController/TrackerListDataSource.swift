//
//  TrackerListDataSource.swift
//  getlocation
//
//  Created by Oleg Komaristy on 21.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class TrackerListDataSource: GenericDataSource<TrackerViewModel>, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.value.count
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let trackerViewModel = data.value[indexPath.row]
//		if UIDevice.current.userInterfaceIdiom == .phone {	// cell with route preview
//			let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackerCell.self),
//													 for: indexPath) as! TrackerCell
//			cell.configure(with: tracker)
//			return cell
//		} else {	// default title/subtitle cell
//			let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCellSimple", for: indexPath)
//			cell.textLabel?.text = tracker.name
//			cell.detailTextLabel?.text = "\(String(describing: tracker.points?.count ?? 0)) points"
//			return cell
//		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCellSimple", for: indexPath)
		if let cell = cell as? CellConfigurable {
			cell.setup(viewModel: trackerViewModel)
		}
		return cell
    }
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		
		let trackerViewModel = self.data.value[indexPath.row]
		self.eventHandler(.delete, trackerViewModel)
    }
}
