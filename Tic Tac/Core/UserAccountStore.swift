//
//  UserAccountStore.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/12/22.
//

import Foundation
import FirebaseAuth

typealias FIRUser = FirebaseAuth.User

/// Manages serialization, retrieval, and removal of all authenticated users.
/// Does not coordinate with Firebase to manage the current user.
class UserAccountStore {
    static let shared = UserAccountStore()
    private static let storedUserKey = "firebase_auth_stored_user_coder_key"
    
    private(set) var users: [FIRUser] = []
    private let userStorePath: String
    
    private init() {
        self.userStorePath = FileManager.libraryDirectory/"UserAccountStore"
        self.reloadUsersFromDisk()
    }
    
    private func reloadUsersFromDisk() {
        // Ensure directory exists
        guard FileManager.default.directoryExists(atPath: self.userStorePath) else {
            try! FileManager.default.createDirectory(atPath: self.userStorePath, withIntermediateDirectories: true)
            return
        }
        
        // Read user files in user store directory
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: self.userStorePath) else {
            return
        }
        
        // Decode users one by one
        self.users = files.compactMap { filename in
            return self.decodeUser(at: self.userStorePath/filename)
        }
    }
    
    private func filename(for user: FIRUser) -> String {
        return user.uid/".plist"
    }
    
    private func encode(_ user: FIRUser) -> NSData {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(user, forKey: UserAccountStore.storedUserKey)
        return archiver.encodedData as NSData
    }
    
    private func decodeUser(at path: String) -> FIRUser? {
        guard let data = NSData(contentsOfFile: path),
              let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data as Data) else {
            return nil
        }
        
        return unarchiver.decodeObject(of: FIRUser.self, forKey: UserAccountStore.storedUserKey)
    }
    
    func saveOrUpdate(_ user: FIRUser) {
        // Save user to disk
        let filePath = self.userStorePath/self.filename(for: user)
        let userdata = self.encode(user)
        userdata.write(toFile: filePath, atomically: true)
        
        if let idx = self.users.firstIndex(where: { user.uid == $0.uid }) {
            // Update existing user
            self.users[idx] = user
        }
        else {
            // Add new user
            self.users.append(user)
        }
    }
    
    @discardableResult
    func removeUser(with identifier: String) -> FIRUser? {
        let user = self.users.first { user -> Bool in
            user.uid == identifier
        }
        
        self.users.removeAll { user -> Bool in
            user.uid == identifier
        }
        
        return user
    }
}
