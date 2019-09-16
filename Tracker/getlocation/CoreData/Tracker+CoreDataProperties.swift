//
//  Tracker+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData


extension Tracker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tracker> {
        return NSFetchRequest<Tracker>(entityName: "Tracker")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var points: Set<Point>?

}

// MARK: Generated accessors for points
extension Tracker {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: Point)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: Point)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}
