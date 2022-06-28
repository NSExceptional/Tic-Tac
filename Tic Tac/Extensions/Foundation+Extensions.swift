//
//  Foundation+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/14/22.
//

import Foundation
import CoreLocation

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
}

@dynamicMemberLookup
class Defaults {
    private static let std = UserDefaults.standard
    static let standard: Defaults = .init()
    
    private init() { }
    
    subscript(dynamicMember member: String) -> String? {
        get {
            return Self.std.string(forKey: member)
        }
        set {
            Self.std.set(newValue, forKey: member)
        }
    }
    
    subscript(dynamicMember member: String) -> Bool {
        get {
            return Self.std.bool(forKey: member)
        }
        set {
            Self.std.set(newValue, forKey: member)
        }
    }
    
    subscript(dynamicMember member: String) -> Int {
        get {
            return Self.std.integer(forKey: member)
        }
        set {
            Self.std.set(newValue, forKey: member)
        }
    }
}
