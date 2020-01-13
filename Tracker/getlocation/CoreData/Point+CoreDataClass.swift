//
//  Point+CoreDataClass.swift
//  
//
//  Created by Oleg Komaristy on 09.09.2019.
//
//

import Foundation
import CoreData


public class Point: NSManagedObject {
	convenience public init() {
		let context = CoreDataManager.shared.context
		guard let entity = NSEntityDescription.entity(forEntityName: String(describing: Point.self), in: context) else {
			fatalError("Could not create entity of Point")
		}
		
		self.init(entity: entity, insertInto: context)
	}
}
