//
//  GenericDataSource.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class GenericDataSource<Model>: NSObject, UITableViewDataSource {
	enum Event {
		case insert
		case delete
	}

	typealias CellConfigurator = (Model, UITableViewCell) -> Void
	typealias EventHandler = (Event, Model) -> Void

	/// The array of models managed by data source
	var models: Dynamic<[Model]>

	/// The reuse indentifier of table view cell
	private let reuseIdentifier: String

	/// A block to execute when configurating the cell.
	private let cellConfigurator: CellConfigurator

	/// A block to execute when one of the events occured with the data source
	private let eventHandler: EventHandler

	/// A Boolean value that indicates whether the table view data source content can be edited
	public var isEditable: Bool

	init(models: Dynamic<[Model]>, isEditable: Bool = false, reuseIdentifier: String, cellConfigurator: @escaping CellConfigurator, eventHandler: @escaping EventHandler) {
		self.models = models
		self.isEditable = isEditable
		self.reuseIdentifier = reuseIdentifier
		self.cellConfigurator = cellConfigurator
		self.eventHandler = eventHandler
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return models.value.count
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditable
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = models.value[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

		cellConfigurator(model, cell)

		return cell
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

		let model = self.models.value[indexPath.row]
		eventHandler(.delete, model)
    }
}

class GenericSectionedDataSource: NSObject, UITableViewDataSource {
	private let dataSources: [UITableViewDataSource]

	init(dataSources: [UITableViewDataSource]) {
		self.dataSources = dataSources
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let dataSource = dataSources[section]
		return dataSource.tableView(tableView, numberOfRowsInSection: 0)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let dataSource = dataSources[indexPath.section]
		let _indexPath = IndexPath(row: indexPath.row, section: 0)
		return dataSource.tableView(tableView, cellForRowAt: _indexPath)
	}
}
