//
//  ObjectData.swift
//  gpstracky
//
//  Created by Олег Комаристый on 09.06.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import Foundation

typealias Tracker = [TrackerPoint]

class TrackerPoint {
    
    var latitude: Double
    var longitude: Double
    var timestamp: Int64
    
    init(latitude: Double, longitude: Double, date: Int64) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = date
    }
}
