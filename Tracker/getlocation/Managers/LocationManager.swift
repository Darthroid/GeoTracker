//
//  LocationManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 16.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: CLLocationManager {
    static let shared = CLLocationManager()
    
    private override init() {
        //
    }
}
