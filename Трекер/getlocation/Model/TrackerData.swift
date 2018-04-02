//
//  TrackerData.swift
//  getlocation
//
//  Created by Олег Комаристый on 02.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit

class TrackerData: NSObject {
  var latitude: Double
  var longitude: Double
  var id: String
  var timeStamp: String
  
  init(latitude: Double, longitude: Double, id: String, timeStamp: String) {
    self.latitude = latitude
    self.longitude = longitude
    self.id = id
    self.timeStamp = timeStamp
  }
}
