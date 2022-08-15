//
//  YYClient+AuthManagement.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import YakKit

extension YYClient {
    /// A list of all managed sessions.
    private(set) static var sessions: [YYClient] = []
    
    /// To change the current client, set it to `.newManagedSession()`.
    /// Both sessions will be stored in `YYClient.sessions`.
    static var current: YYClient = .newManagedSession()
    
    /// Create a new session and store it in `YYClient.sessions`.
    static func newManagedSession() -> YYClient {
        let s = YYClient()
        self.sessions.append(s)
        return s
    }
    
    var isLoggedIn: Bool {
        self.authToken != nil
    }
    
//    var allUsers: [YYUser]
}
