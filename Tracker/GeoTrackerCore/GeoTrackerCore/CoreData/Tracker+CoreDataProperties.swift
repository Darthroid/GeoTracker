//
//  Tracker+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData

public extension Tracker {

	@nonobjc class func fetchRequest() -> NSFetchRequest<Tracker> {
        return NSFetchRequest<Tracker>(entityName: "Tracker")
    }

	@NSManaged var id: String
    @NSManaged var name: String?
    @NSManaged var points: Set<TrackerPoint>?

}

// MARK: Generated accessors for points
public extension Tracker {

    @objc(addPointsObject:)
    @NSManaged func addToPoints(_ value: TrackerPoint)

    @objc(removePointsObject:)
    @NSManaged func removeFromPoints(_ value: TrackerPoint)

    @objc(addPoints:)
    @NSManaged func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged func removeFromPoints(_ values: NSSet)

}
