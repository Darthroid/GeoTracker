//
//  CoreDataManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import CoreData


public protocol CoreDataObserver: class {
	func didInsert(ids: [String], trackers: [Tracker])
	func didUpdate(ids: [String], trackers: [Tracker])
	func didDelete(ids: [String], trackers: [Tracker])
}

public class CoreDataManager {
    public static var shared = CoreDataManager()
    
    private let persistentContainer = NSPersistentContainer(name: "TrackerDataModel")
	
	private var observations = [ObjectIdentifier: Observation]()
    
    public var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func initalizeStack(completion: @escaping () -> Void) {
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("could not load store \(error.localizedDescription)")
                return
            }
            print(self, #function, "store loaded")
        }
    }
    
    func setStore(type: String) {
        let description = NSPersistentStoreDescription()
        description.type = type // types: NSInMemoryStoreType, NSSQLiteStoreType, NSBinaryStoreType
        
        if type == NSSQLiteStoreType || type == NSBinaryStoreType {
            description.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?.appendingPathComponent("database")
        }
        
        self.persistentContainer.persistentStoreDescriptions = [description]
    }
    
    // MARK: - Create (Insert)
    
    func insertTracker(withId id: String, name: String, points: [Point] = []) throws {
        let tracker = Tracker(context: self.context)
        tracker.id = id
        tracker.name = name
        
        points.forEach({ tracker.addToPoints($0)})
        
        self.context.insert(tracker)
		self.event(.insert, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }
    
    // MARK: - Read (Fetch)
    
    func fetchTrackers() throws -> [Tracker] {
        let request = Tracker.fetchRequest() as NSFetchRequest<Tracker>
        let trackers = try self.context.fetch(request)
        return trackers
    }
    
    func fetchTrackers(withId id: String) throws -> [Tracker] {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let trackers = try self.context.fetch(request)
        return trackers
    }
    
    func fetchTrackers(withName name: String) throws -> [Tracker] {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "name == %@", name)
        
        let trackers = try self.context.fetch(request)
        return trackers
    }
    
    // MARK: - Update
    // TODO: update with another parameters
    func update(tracker: Tracker, points: [Point]) throws {
        points.forEach({ tracker.addToPoints($0) })
		self.event(.update, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }
    
    // MARK: - Delete

    func delete(tracker: Tracker) throws {
        self.context.delete(tracker)
		self.event(.delete, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }
	
	// unused
    func deleteTrackers(withId id: String) throws {
        let fetchRequest = Tracker.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
//		self.event(.delete, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }
}

// TODO: - replace observation method with CoreData default tools
private extension CoreDataManager {
	struct Observation {
		weak var observer: CoreDataObserver?
	}
	
	enum Event {
		case insert
		case delete
		case update
	}
	
	func event(_ event: Event, ids: [String], trackers: [Tracker]) {
		for (id, observation) in observations {
			// If the observer is no longer in memory, we
			// can clean up the observation for its ID
			guard let observer = observation.observer else {
				observations.removeValue(forKey: id)
				continue
			}
			
			switch event {
			case .insert:
				observer.didInsert(ids: ids, trackers: trackers)
			case .update:
				observer.didUpdate(ids: ids, trackers: trackers)
			case .delete:
				observer.didDelete(ids: ids, trackers: trackers)
			}
		}
	}
}

public extension CoreDataManager {
	func addObserver(_ observer: CoreDataObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

	func removeObserver(_ observer: CoreDataObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

