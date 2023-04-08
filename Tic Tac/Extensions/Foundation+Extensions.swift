//
//  Foundation+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/14/22.
//

import Foundation
import CoreLocation

extension String {
    static func / (lhs: String, rhs: String) -> String {
        return (lhs as NSString).appendingPathComponent(rhs)
    }
}

extension NSException {
    static func raise(name: NSExceptionName, message: String) -> Never {
        self.raise(name, format: message, arguments: getVaList([]))
        fatalError()
    }
}

extension Date {
    static func-(lhs: Self, rhs: Self) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}

extension Data {
    init(contentsOfFile path: String) throws {
        let url = URL(fileURLWithPath: path)
        self = try .init(contentsOf: url)
    }
    
    func writeToFile(_ path: String) throws {
        let url = URL(fileURLWithPath: path)
        try self.write(to: url, options: [.atomic])
    }
    
    func read<T>() -> T {
        return self.withUnsafeBytes { ptr -> T in
            return ptr.load(as: T.self)
        }
    }
}

extension CLLocation {
    convenience init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Result {
    var failed: Bool {
        if case .failure(_) = self {
            return true
        }
        
        return false
    }
    
    var succeeded: Bool {
        return !self.failed
    }
    
    var value: Success? {
        return try? self.get()
    }
    
    var error: Failure? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
}

extension FileManager {
    @objc class var documentsDirectory: String {
        return self.directory(for: .documentDirectory)
    }
    
    @objc class var libraryDirectory: String {
        return self.directory(for: .documentDirectory)
    }
    
    @objc func directoryExists(atPath folder: String) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: folder, isDirectory: &isDir)
        return exists && isDir.boolValue
    }
    
    @objc private class func directory(for path: SearchPathDirectory) -> String {
        return NSSearchPathForDirectoriesInDomains(
            path, .userDomainMask, true
        )[0]
    }
}

extension NotificationCenter {
    func observe<T>(_ notification: NSNotification.Name, using block: @escaping (_ obj: T) -> Void) {
        self.addObserver(forName: notification, object: nil, queue: nil) { notif in
            block(notif.object as! T)
        }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func uniqued() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter {
            let didInsert = seen.insert($0).inserted
            return didInsert
        }
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        self.removeAll { $0 == element }
    }
}

extension Optional {
    static func +<T>(ls: [T]?, rs: [T]?) -> [T] {
        switch (ls, rs) {
            case (.none, .none):
                return []
            case (.some(let a), .none):
                return a
            case (.none, .some(let a)):
                return a
            case (.some(let a), .some(let b)):
                return a + b
        }
    }
}
