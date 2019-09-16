//
//  CoreDataManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import CoreData
//import UIKit

public class CoreDataManager {
    public static var shared = CoreDataManager()
    
    private let persistentContainer = NSPersistentContainer(name: "TrackerDataModel")
    
    var context: NSManagedObjectContext {
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
    
    func insertTracker(with id: String, points: [TrackerPoint] = []) throws {
        let tracker = Tracker(context: self.context)
        tracker.id = id
        
        points.forEach({ [unowned self] _point in
            let point = Point(context: self.context)
            point.id = _point.id
            point.latitude = _point.latitude
            point.longitude = _point.longitude
            point.timestamp = _point.timestamp
            
            tracker.addToPoints(point)
        })
        
        self.context.insert(tracker)
        if self.context.hasChanges {
            try self.context.save()
        }
    }
    
    // MARK: - Read (Fetch)
    
    func fetchTrackers() throws -> [Tracker] {
        let trackers = try self.context.fetch(Tracker.fetchRequest() as NSFetchRequest<Tracker>)
        return trackers
    }
    
    func fetchTrackers(withId id: String) throws -> [Tracker] {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let trackers = try self.context.fetch(request)
        return trackers
    }
    
    // MARK: - Update
    // TODO: update with another parameters
    func update(tracker: Tracker, points: [Point]) throws {
        points.forEach({ tracker.addToPoints($0) })
        if self.context.hasChanges {
            try self.context.save()
        }
    }
    
    // MARK: - Delete

    func delete(tracker: Tracker) throws {
        self.context.delete(tracker)
        if self.context.hasChanges {
            try self.context.save()
        }
    }

    func deleteTrackers(withId id: String) throws {
        let fetchRequest = Tracker.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
        if self.context.hasChanges {
            try self.context.save()
        }
    }
}
