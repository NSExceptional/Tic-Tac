//
//  Decorators.swift
//  Receiptie
//
//  Created by Tanner Bennett on 3/30/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation
import GRDB

extension Entity {
    typealias HasOne<T> = AnyHasOne<Self, T> where T: Entity
    typealias HasMany<T> = AnyHasMany<Self, T> where T: Entity
}

@propertyWrapper struct AnyHasOne<EnclosingType, Value>
where EnclosingType: Entity, Value: Entity {
    typealias WrappedKeyPath = ReferenceWritableKeyPath<EnclosingType, Value?>
    typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>
    
    static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: WrappedKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> Value? {
        get {
            if let cached = instance[keyPath: storageKeyPath].storage {
                return cached
            }
            
            let request = instance.request(for: EnclosingType.belongsTo(Value.self))
            let result: Value? = try! Container.shared.fetch(request)
            instance[keyPath: storageKeyPath].storage = result
            
            return result
        }
        set {
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }
    
    @available(*, unavailable,
        message: "This property wrapper can only be applied to classes"
    )
    var wrappedValue: Value? {
        get { fatalError() }
        set { fatalError() }
    }
    
    private var storage: Value? = nil
    
    init(_ value: Value? = nil, wrappedValue: Value?) {
        self.storage = value
    }
}

@propertyWrapper struct AnyHasMany<EnclosingType, Value>
where EnclosingType: Entity, Value: Entity {
    typealias WrappedKeyPath = ReferenceWritableKeyPath<EnclosingType, [Value]>
    typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>
    
    static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: WrappedKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> [Value] {
        get {
            if let cached = instance[keyPath: storageKeyPath].storage, !cached.isEmpty {
                return cached
            }
            
            let request = instance.request(for: EnclosingType.hasMany(Value.self))
            let result: [Value] = try! Container.shared.fetch(request)
            instance[keyPath: storageKeyPath].storage = result
            
            return result
        }
        set {
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }
    
    @available(*, unavailable,
        message: "This property wrapper can only be applied to classes"
    )
    var wrappedValue: [Value] {
        get { fatalError() }
        set { fatalError() }
    }
    
    private var storage: [Value]? = nil
    
    init(_ value: [Value] = [], wrappedValue: [Value]) {
        self.storage = value
    }
}
