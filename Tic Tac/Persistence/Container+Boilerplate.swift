//
//  Container+Receipt.swift
//  Receiptie
//
//  Created by Tanner Bennett on 2/18/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation
import GRDB
import YakKit

extension Container {
    func user(with identifier: String) -> UserTag? {
        return try? self.fetch(UserTag.filter(Column("id") == identifier))
    }
    
    func insert(newUser: UserTag, notify: Bool = true) throws {
        precondition(newUser.id != nil)
        try self.insert(newUser, notify: notify)
    }
    
    func update(user newTag: UserTag) throws {
        try self.update(newTag)
    }
}

extension Container {
    func post(with identifier: String) -> YYYak? {
        guard let stored: YYStoredPost = try! self.fetch(YYStoredPost.filter(Column("id") == identifier)) else {
            return nil
        }
        
        return YYYak(from: stored)
    }
    
    func insert(newPost votable: YYYak, notify: Bool = true) throws {
        try self.insert(YYStoredPost(from: votable), notify: notify)
    }
}

extension Container {
    func comment(with identifier: String) -> YYComment? {
        guard let stored: YYStoredComment = try! self.fetch(YYStoredComment.filter(Column("id") == identifier)) else {
            return nil
        }
        
        return YYComment(from: stored)
    }
    
    func insert(newComment votable: YYYak, notify: Bool = true) throws {
        try self.insert(YYStoredComment(from: votable), notify: notify)
    }
}
