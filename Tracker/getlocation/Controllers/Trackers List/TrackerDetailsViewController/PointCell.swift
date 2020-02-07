//
//  PointCell.swift
//  getlocation
//
//  Created by Oleg Komaristy on 26.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class PointCell: UITableViewCell, CellConfigurable {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func setup(viewModel: RowViewModel) {
		guard let pointModel = viewModel as? PointViewModel else {
			assert(false)
			return
		}
		
		self.textLabel?.text = pointModel.dateString()
		self.detailTextLabel?.text = pointModel.description
	}
}
