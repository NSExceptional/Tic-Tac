//
//  Defaults.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/11/22.
//

import Foundation

/// Creates a property on UserDefaults with the given key
@propertyWrapper
struct Setting<T> {
    
    var key: String
    var wrappedValue: T? {
        get {
            UserDefaults.standard.object(forKey: self.key) as? T
        }
        nonmutating set {
            UserDefaults.standard.set(newValue, forKey: self.key)
        }
    }
    
    init(_ key: String) {
        self.key = key
    }
}

/// Maps a property on another type to a user defaults property; calls into a `@Setting`
@propertyWrapper
struct Defaults<T> {
    typealias DefaultsKeyPath = ReferenceWritableKeyPath<UserDefaultsStore, T?>
    var key: DefaultsKeyPath
    
    var wrappedValue: T? {
        get {
            UserDefaultsStore.standard[keyPath: self.key]
        }
        set {
            UserDefaultsStore.standard[keyPath: self.key] = newValue
        }
    }
    
    init(_ key: DefaultsKeyPath) {
        self.key = key
    }
}


/// Only exists as a workaround for "extensions cannot contain stored properties"
/// and "key path cannot refer to static member"
struct UserDefaultsStore {
    static let standard: UserDefaultsStore = .init()
    
    /// The unique name of the currently selected location, or nil to use the real location.
    @Setting("selectedLocation") var selectedLocation: String?
    /// The current user's Yik Yak auth token.
    @Setting("authToken") var authToken: String?
}
