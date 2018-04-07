//
//  Data+CoreDataClass.swift
//  getlocation
//
//  Created by Олег Комаристый on 21.06.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import Foundation
import CoreData

@objc(Data)
public class Data: NSManagedObject {
    convenience init() {
        // Описание сущности
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Data"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
