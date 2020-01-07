//
//  CustomPointAnnotation.swift
//  getlocation
//
//  Created by Олег Комаристый on 07.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import MapKit

/// Custom implementation of MKPointAnnotation
// currently used for removing annotations except start and finish, but maybe will be customized more in future
class CustomPointAnnotation : MKPointAnnotation {
    var id: String?
}
