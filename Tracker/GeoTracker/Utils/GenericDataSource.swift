//
//  GenericDataSource.swift
//  getlocation
//
//  Created by Олег Комаристый on 19.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

class GenericDataSource<T> : NSObject {
	enum Event {
		// TODO: events
		case insert
		case delete
	}
	
    var data: Dynamic<[T]> = Dynamic([])
	
	var eventHandler: (Event, T) -> Void
	
	public init(eventHandler: @escaping (Event, T) -> Void) {
		self.eventHandler = eventHandler
	}
}
