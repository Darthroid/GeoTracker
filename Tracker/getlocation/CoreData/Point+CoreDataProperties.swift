//
//  Point+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData
import CoreLocation

extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var id: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Int64
    @NSManaged public var tracker: Tracker?

}

extension Point {
	public func toCLLocationCoordinates() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
}
