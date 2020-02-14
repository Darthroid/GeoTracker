//
//  TrackerPoint+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData
import CoreLocation

public extension TrackerPoint {

    @nonobjc class func fetchRequest() -> NSFetchRequest<TrackerPoint> {
        return NSFetchRequest<TrackerPoint>(entityName: "TrackerPoint")
    }

    @NSManaged var id: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var timestamp: Int64
    @NSManaged var tracker: Tracker?
}
