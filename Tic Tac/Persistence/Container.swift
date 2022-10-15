//
//  Container.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 2/13/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import UIKit
import GRDB

class Container {
    enum Event<E: Entity> {
        case insert([E])
        case update([E])
        case delete([E])
        
        var entity: E {
            return self.entities.first!
        }
        
        var entities: [E] {
            switch self {
                case .insert(let e): return e
                case .update(let e): return e
                case .delete(let e): return e
            }
        }
    }
    
    enum Error: Swift.Error {
        case exists(Entity)
        case notExists
        case other(Swift.Error)
    }
    
    typealias Subscriber<E: Entity> = (Event<E>) -> Void
    
    public static let shared = Container()
    
    private static var dbPath: String {
        let folder = FileManager.documentsDirectory as NSString
        let path = folder.appendingPathComponent("tictac.db")
        
        #if DEBUG
        // Nuke the database on launch
        // try? FileManager.default.removeItem(atPath: path)
        #endif
        
        return path
    }
    
    private init() {
        try! self.migrator.migrate(self.q)
    }
    
    internal let q = try! DatabaseQueue(path: Container.dbPath)
    
    private var tableSubscribers: [String: [Any]] = [:]
    private var entitiySubscribers: [String: [Any]] = [:]
    
    /// <https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
//        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("v1.0") { db in
            try self.createTables(db)
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }
    
    func subscribe<E: Entity>(to table: E.Type, notify subscriber: @escaping Subscriber<E>) {
        self.tableSubscribers["\(table)", default: []].append(subscriber)
    }
    
    func subscribe<E: Entity>(to entity: E, notify subscriber: @escaping Subscriber<E>) {
        self.entitiySubscribers[entity.key, default: []].append(subscriber)
    }
    
    func manuallyNotifySubscribers<E: Entity>(of event: Event<E>) {
        self.notifySubscribers(of: event)
    }
    
    private func notifySubscribers<E: Entity>(of event: Event<E>) {
        for sub in self.entitiySubscribers[event.entity.key, default: []] {
            let block = sub as! Subscriber<E>
            block(event)
        }
        
        for sub in self.tableSubscribers["\(E.self)", default: []] {
            let block = sub as! Subscriber<E>
            block(event)
        }
    }
}

extension Container {
    @discardableResult
    func insertIfNotExists<T: Entity>(_ record: T, notify: Bool = true) throws -> T {
        if let existing = try self.fetch(T.filter(Column("id") == record.id)) {
            return existing
        }
        
        try self.q.write { db in
            return try record.insert(db)
        }
        
        defer {
            if notify {
                self.notifySubscribers(of: .insert([record]))
            }
        }
        return record
    }
    
    @discardableResult
    func insert<T: Entity>(_ record: T, notify: Bool = true) throws -> T {
        try self.q.write { db in
            try record.insert(db)
        }
        
        defer {
            if notify {
                self.notifySubscribers(of: .insert([record]))
            }
        }
        return record
    }
    
    @discardableResult
    func update<T: Entity>(_ record: T, notify: Bool = true) throws -> T {
        precondition(record.id != nil)
        
        try self.q.write { db in
            try record.update(db)
        }
        
        defer {
            if notify {
                self.notifySubscribers(of: .update([record]))
            }
        }
        return record
    }
    
    @discardableResult
    func update<N: Entity>(_ record: Entity?, notifier: N) throws -> Entity? {
        guard let record = record else { return nil }
        precondition(record.id != nil)
        
        try self.q.write { db in
            try record.bugFix?.update(db)
        }
        
        defer { self.notifySubscribers(of: .update([notifier])) }
        return record
    }
    
    /// Fetch a single complete Entity
    func fetch<T: Entity>(_ query: QueryInterfaceRequest<T>) throws -> T? {
        try self.q.read { db in try query.fetchOne(db) }
    }
    
    /// Fetch many Entities
    func fetch<T: Entity>(_ query: QueryInterfaceRequest<T>) throws -> [T] {
        try self.q.read { db in try query.fetchAll(db) }
    }
    
    /// Select a column from a single Entity
    func fetch<T: DatabaseValueConvertible, E: Entity>(
            key: String,
            from query: QueryInterfaceRequest<E>) throws -> T? {
        return try self.q.read { db in
            // SELECT key FROM ...
            let query = query.select(Column(key), as: T.self)
            return try query.fetchOne(db)
        }
    }
    
    /// Select a column from many Entities
    func fetch<T: DatabaseValueConvertible, E: Entity>(
            key: String,
            from query: QueryInterfaceRequest<E>) throws -> [T] {
        return try self.q.read { db in
            // SELECT key FROM ...
            let query = query.select(Column(key), as: T.self)
            return try query.fetchAll(db)
        }
    }
    
    /// Fetch all of the given Entity
    func fetchAll<T: Entity>(_ type: T.Type = T.self) -> [T] {
        return (try? self.fetch(T.all())) ?? []
    }
    
    @discardableResult
    func delete<T: Entity>(_ record: T, notify: Bool = true) throws -> Bool {
        precondition(record.id != nil)
        
        defer {
            if notify {
                self.notifySubscribers(of: .delete([record]))
            }
        }
        
        return try self.q.write { db in
            try record.delete(db)
        }
    }
    
    func deleteAll<T: Entity>(_ records: [T]) throws {
        for r in records {
            try self.delete(r)
        }
    }
    
    func count<T: Entity>(_ query: QueryInterfaceRequest<T>) throws -> Int {
        return try self.q.read { db in
            return try query.fetchCount(db)
        }
    }
}

extension Container {
    /// First argument: old value
    /// Second argument: closure accepting a new value
    typealias EditBlock<T> = (T, @escaping (T) throws -> Void) -> Void
    /// First argument: old values
    /// Second argument: closure accepting new values
    typealias MultiEditBlock<T> = ([T], @escaping ([T]) throws -> Void) -> Void
    
    func edit<T, E: Entity>(entity: E, keyPath path: EditableEntityKeyPath<E, T>, edits: EditBlock<T>) {
        let oldValue = entity[keyPath: path.propertyKey]
        
        edits(oldValue) { newValue in
            entity[keyPath: path.propertyKey] = newValue
            
            // Update the affected entity, if any, or the given entity.
            // In either case, only notify about the given entity.
            if let target = path.affectedEntity {
                try self.update(entity[keyPath: target], notifier: entity)
            } else {
                try self.update(entity)
            }
        }
    }
    
    func edit<T, E: Entity>(entity: E, keyPaths paths: [EditableEntityKeyPath<E, T>], edits: MultiEditBlock<T>) {
        let oldValues = paths.map { entity[keyPath: $0.propertyKey] }
        
        edits(oldValues) { newValues in
            try zip(paths, newValues).forEach {
                entity[keyPath: $0.propertyKey] = $1
                // Update the affected entity directly, if any
                if let target = $0.affectedEntity {
                    try self.update(entity[keyPath: target], notifier: entity)
                }
            }
            
            // Defer updates to the root entity untilt the end,
            // even if no changes were made; subscribers probably
            // care more about this entity than its proerties
            try self.update(entity)
        }
    }
}

private extension Entity {
    var key: String {
        precondition(self.id != nil)
        return "\(type(of: self))-\(self.id!)"
    }
}
