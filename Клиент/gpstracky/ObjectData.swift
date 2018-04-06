//
//  ObjectData.swift
//  gpstracky
//
//  Created by Олег Комаристый on 09.06.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import Foundation
class ObjectData: NSObject {

  var latitude: Double
  var longitude: Double
  var date: String

  init(latitude: Double, longitude: Double, date: String) {
    self.latitude = latitude
    self.longitude = longitude
    self.date = date
  }
}
