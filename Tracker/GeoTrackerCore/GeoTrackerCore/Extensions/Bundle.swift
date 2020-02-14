//
//  Bundle.swift
//  getlocation
//
//  Created by Oleg Komaristy on 16.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation

public extension Bundle {
    var displayName: String {
        return  object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String ??
                "GeoTracker"
    }
}
