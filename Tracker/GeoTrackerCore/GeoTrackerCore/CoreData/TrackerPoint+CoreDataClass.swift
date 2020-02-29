//
//  TrackerPoint+CoreDataClass.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData

public class TrackerPoint: NSManagedObject {
	convenience public init() {
		let context = CoreDataManager.shared.context
		let entityName = String(describing: TrackerPoint.self)
		guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
			fatalError("Could not create entity of TrackerPoint")
		}

		self.init(entity: entity, insertInto: context)
	}
}
