//
//  UITableView.swift
//  getlocation
//
//  Created by Олег Комаристый on 04.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func setNoDataPlaceholder(_ message: String) {
        let label = UILabel(frame: CGRect(x: self.bounds.size.width / 2,
										  y: self.bounds.size.width / 2,
										  width: self.bounds.size.width,
										  height: self.bounds.size.height))
        label.text = message
        // styling
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20.0)
		if #available(iOS 13.0, *) {
			label.textColor = UIColor.placeholderText
		} else {
			label.textColor = UIColor.gray
		}

        label.sizeToFit()

        self.isScrollEnabled = false
        self.backgroundView = label
        self.separatorStyle = .none
    }

    func removeNoDataPlaceholder() {
        self.isScrollEnabled = true
        self.backgroundView = nil
		self.separatorStyle = UIDevice.current.userInterfaceIdiom == .phone ? .none : .singleLine
    }
}
