//
//  Entity.swift
//  Receiptie
//
//  Created by Tanner Bennett on 4/1/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation
import GRDB

protocol Entity: AnyObject, Codable, FetchableRecord, PersistableRecord {
    var id: String? { get set }
}

extension Entity {
    /// Enables returning `self` as a key path expecting an Entity
    var entitySelf: Entity? { return self }
    
    func fetchSelf(_ db: Container) throws -> Self {
        guard let id = self.id else { preconditionFailure("Cannot fetch self without an ID") }
        return try db.fetch(Self.filter(Column("id") == id))!
    }
}

class EditableEntityKeyPath<E: Entity, V> {
    typealias PropertyKey = ReferenceWritableKeyPath<E, V>
    typealias EntityKey = KeyPath<E, Entity?>
    
    let name: String
    let propertyKey: PropertyKey
    let affectedEntity: EntityKey?
    
    init(_ name: String, _ key: PropertyKey, affected: EntityKey? = nil) {
        self.name = name
        self.propertyKey = key
        self.affectedEntity = affected
    }
}

extension Entity {
    var bugFix: Entity? {
        return self as? UserTag
    }
}
