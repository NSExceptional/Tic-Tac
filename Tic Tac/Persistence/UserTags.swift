//
//  UserTags.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/23/22.
//

import YakKit

class UserTags {
    private static var random = SystemRandomNumberGenerator()
    
    class func tag(for user: YYUser) -> String? {
        return random.next().isMultiple(of: 2) ? "user tag here" : nil
    }
    
    class func tag(for userID: String) -> String? {
        return random.next().isMultiple(of: 2) ? "user tag here" : nil
    }
}
