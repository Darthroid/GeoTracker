//
//  DateManager.swift
//  gpstracky
//
//  Created by Oleg Komaristy on 04.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation

class DateManager {
    static func timestampToString(_ timestamp: Int64?) -> String {
        guard let timestamp = timestamp else { return "" }
        let timeInt: TimeInterval = Double(timestamp) / 1000
        let date = Date(timeIntervalSince1970: timeInt)

        return String(describing: date)
    }
}
