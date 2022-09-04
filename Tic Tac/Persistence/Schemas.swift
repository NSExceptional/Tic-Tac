//
//  Schemas.swift
//  Receiptie
//
//  Created by Tanner Bennett on 2/13/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation
import GRDB

extension Database {
    enum DSLColumn {
        case required(_ name: String, _ type: GRDB.Database.ColumnType)
        case nullable(_ name: String, _ type: GRDB.Database.ColumnType)
        case relation(_ name: String, _ table: String, cascade: Bool)
    }
    
    fileprivate func create(table tableName: String, columns: [DSLColumn]) throws {
        try self.create(table: tableName) { t in
            t.column("id", .text).primaryKey()
            
            for c in columns {
                switch c {
                    case let .required(name, type):
                        t.column(name, type).notNull()
                    case let .nullable(name, type):
                        t.column(name, type)
                    case let .relation(name, reference, cascade):
                        t.column(name, .integer)
                            .indexed()
                            .references(reference,
                                onDelete: cascade ? .cascade : .none
                            )
                }
            }
        }
    }
}

extension Container {
    func createTables(_ db: Database) throws {
        let schemas = [
            ("userTag", userTagSchema),
            ("post", postSchema),
            ("comment", commentSchema),
        ]
        
        for (table, cols) in schemas {
            try db.create(table: table, columns: cols)
        }
    }
    
    private var userTagSchema: [Database.DSLColumn] { [
        .required("gender", .text),
        .required("party", .text),
        .nullable("text", .text),
        .nullable("pastEmojis", .text),
    ] }
    
    private var votableSchema: [Database.DSLColumn] { [
        .relation("userId", "userTag", cascade: false),
        
        .required("createdAt", .datetime),
        .required("text", .text),
        .required("emoji", .text),
        .required("userColor", .text),
        .required("secondaryUserColor", .text),
        .required("voteCount", .integer),
        
        .nullable("locationName", .text),
        .nullable("lat", .double),
        .nullable("lng", .double),
    ] }
    
    private var postSchema: [Database.DSLColumn] {
        votableSchema
    }
    
    private var commentSchema: [Database.DSLColumn] {
        [.relation("parentId", "post", cascade: false)] + votableSchema
    }
}
