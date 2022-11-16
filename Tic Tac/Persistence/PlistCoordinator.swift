//
//  PlistCoordinator.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import UIKit

struct PlistCoordinator<T: Codable> {
    enum Location {
        case documents
        case library
        case temporary
        
        private var directory: FileManager.SearchPathDirectory? {
            switch self {
                case .documents:
                    return .documentDirectory
                case .library:
                    return .libraryDirectory
                case .temporary:
                    return nil
            }
        }
        
        private var resolved: NSString {
            guard let dir = self.directory else {
                return NSTemporaryDirectory() as NSString
            }
            
            let paths = NSSearchPathForDirectoriesInDomains(dir, .userDomainMask, true)
            return paths.first! as NSString
        }
        
        func path(with filename: String) -> String {
            let fullFilename = filename.hasSuffix(".plist") ? filename : filename.appending(".plist")
            return self.resolved.appendingPathComponent(fullFilename)
        }
    }
    
    private let filePath: String
    private let defaultValue: T
    private var value: T?
    
    init(in location: Location, named filename: String, default value: T) {
        self.defaultValue = value
        self.filePath = location.path(with: filename)
    }
    
    mutating func getValue() -> T {
        if let value = self.value {
            return value
        }
        
        return self.read()
    }
    
    mutating func read() -> T {
        self.value = nil
        
        if let data = try? Data(contentsOfFile: self.filePath) {
            let decoder = PropertyListDecoder()
            if let value = try? decoder.decode(T.self, from: data) {
                self.value = value
                return value
            }
        }
        
        return self.defaultValue
    }
    
    mutating func write(_ value: T) throws {
        self.value = value
        let data = try PropertyListEncoder().encode(value)
        try data.writeToFile(self.filePath)
    }
}
