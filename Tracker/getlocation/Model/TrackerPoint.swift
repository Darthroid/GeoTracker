//
//  TrackerData.swift
//  getlocation
//
//  Created by Олег Комаристый on 02.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit

class TrackerPoint {
    var latitude: Double
    var longitude: Double
    var id: String
    var timestamp: Int64
    
    public init(latitude: Double, longitude: Double, id: String, timestamp: Int64) {
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        self.timestamp = timestamp
    }
}
