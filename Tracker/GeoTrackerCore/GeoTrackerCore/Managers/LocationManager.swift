//
//  LocationManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 16.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation

public class LocationManager: CLLocationManager {
    public static let shared = CLLocationManager()

    private override init() {
		super.init()
//        self.requestWhenInUseAuthorization()
        self.allowsBackgroundLocationUpdates = true
        self.pausesLocationUpdatesAutomatically = false
    }
}
