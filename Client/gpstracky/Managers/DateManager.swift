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
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)

        return String(describing: strDate)
    }
}
