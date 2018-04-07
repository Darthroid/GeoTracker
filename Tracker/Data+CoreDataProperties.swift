//
//  Data+CoreDataProperties.swift
//  getlocation
//
//  Created by Олег Комаристый on 21.06.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import Foundation
import CoreData


extension Data {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Data> {
        return NSFetchRequest<Data>(entityName: "Data")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var id: String?

}
