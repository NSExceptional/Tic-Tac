//
//  Effect.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 9/25/22.
//

import Foundation

@propertyWrapper
struct Effect<T> {
    struct Observer {
        public var willSet: () -> Void = { }
        public var didSet: () -> Void = { } {
            didSet {
                self.didSet()
            }
        }
    }
    
    public var effect: Observer = .init()
    
    var wrappedValue: T {
        willSet { effect.willSet() }
        didSet { effect.didSet() }
    }

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    /// `didSet` is invoked upon mutation of this value
    var projectedValue: Observer {
        get { effect }
        set { effect = newValue }
    }
}
