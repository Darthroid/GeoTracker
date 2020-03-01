//
//  Date.swift
//  getlocation
//
//  Created by Олег Комаристый on 07.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

public extension Date {
	func stringfromTimeStamp(_ timestamp: Int64) -> String {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd hh:mm:ss"
		let timestampDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
		let dateString = df.string(from: timestampDate)

		return dateString
	}
}
