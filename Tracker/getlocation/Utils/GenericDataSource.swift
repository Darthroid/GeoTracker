//
//  GenericDataSource.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

class GenericDataSource<T> : NSObject {
    var data: Dynamic<[T]> = Dynamic([])
}
