//
//  TrackerDetailsDataSource.swift
//  getlocation
//
//  Created by Oleg Komaristy on 23.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class TrackerDetailsDataSource: GenericDataSource<PointViewModel>, UITableViewDataSource {
	
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
		let pointViewModel = data.value[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "PointCell", for: indexPath)
		if let cell = cell as? CellConfigurable {
			cell.setup(viewModel: pointViewModel)
		}
		return cell
    }
}
