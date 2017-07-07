//
//  PlistHelper.swift
//  gpstracky
//
//  Created by Олег Комаристый on 10.06.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import Foundation
struct PlistFile {
    
    enum PlistError: Error {
        case failedToWrite
        case fileDoesNotExist
    }
    
    let name:String
    
    var sourcePath:String? {
        return Bundle.main.path(forResource: name, ofType: "plist")
    }
    
    var destPath:String? {
        if let _ = sourcePath {
            let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return (dir as NSString).appendingPathComponent("\(name).plist")
        } else {
            return nil
        }
    }
    
    var dictionary : [String:Any]? {
        get{
            return getDictionary()
        }
        set{
            if let newDict = newValue {
                try? write(dictionary: newDict)
            }
        }
    }
    
    var array : [Any]? {
        get{
            return getArray()
        }
        set{
            if let newArray = newValue {
                try? write(array: newArray)
            }
        }
    }
    
    private let fileManager = FileManager.default
    
    init?(named :String) {
        self.name = named
        
        guard let source = sourcePath, let destination = destPath, fileManager.fileExists(atPath: source)  else {
            return nil
        }
        
        if !fileManager.fileExists(atPath: destination) {
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    
    private func getDictionary() -> [String:Any]? {
        guard let destPath = self.destPath, fileManager.fileExists(atPath: destPath) else {
            return nil
        }
        return NSDictionary(contentsOfFile: destPath) as? [String:Any]
    }
    
    private func getArray() -> [Any]? {
        guard let destPath = self.destPath, fileManager.fileExists(atPath: destPath) else {
            return nil
        }
        return NSArray(contentsOfFile: destPath) as? [Any]
    }
    
    func write(dictionary : [String:Any]) throws{
        guard let destPath = self.destPath, fileManager.fileExists(atPath: destPath) else {
            throw PlistError.fileDoesNotExist
        }
        
        if !NSDictionary(dictionary: dictionary).write(toFile: destPath, atomically: false) {
            print("Failed to write the file")
            throw PlistError.failedToWrite
        }
    }
    
    func write(array : [Any] ) throws {
        guard let destPath = self.destPath, fileManager.fileExists(atPath: destPath) else {
            throw PlistError.fileDoesNotExist
        }
        
        if !NSArray(array: array).write(toFile: destPath, atomically: false) {
            print("Failed to write the file")
            throw PlistError.failedToWrite
        }
    }
    
    
}
