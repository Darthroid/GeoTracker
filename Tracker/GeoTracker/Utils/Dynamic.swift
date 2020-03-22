//
//  Dynamic.swift
//  getlocation
//
//  Created by Олег Комаристый on 18.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

typealias CompletionHandler = (() -> Void)
class Dynamic<T>: NSCopying {
	func copy(with zone: NSZone? = nil) -> Any {
		let copy = Dynamic(value)
		return copy
	}

    var value: T {
        didSet {
            self.notify()
        }
    }

    private var observers = [String: CompletionHandler]()

    init(_ value: T) {
        self.value = value
    }

    public func addObserver(_ observer: NSObject, completionHandler: @escaping CompletionHandler) {
        observers[observer.description] = completionHandler
    }

    public func addAndNotify(observer: NSObject, completionHandler: @escaping CompletionHandler) {
        self.addObserver(observer, completionHandler: completionHandler)
        self.notify()
    }

	public func remove(observer: NSObject) {
		self.observers.removeValue(forKey: observer.description)
	}

    private func notify() {
        observers.forEach({ $0.value() })
    }

    deinit {
        observers.removeAll()
    }
}
