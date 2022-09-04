//
//  UserTags.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/23/22.
//

import YakKit

class UserTag: Entity {
    var id: String?
        
    enum Gender: String, Codable {
        case unknown = ""
        case male = "👦🏻"
        case female = "👱🏻‍♀️"
        
        var string: String { self.rawValue }
    }
    
    enum Party: String, Codable {
        case unknown = ""
        case right = "🐘"
        case left = "🧠"
        
        var string: String { self.rawValue }
    }
    
    private static var random = SystemRandomNumberGenerator()
    
    let userIdentifier: String?
    let gender: Gender
    let party: Party
    let text: String?
    
    lazy var detailText: String = self.party.string + " " + self.gender.string
    
    init(gender: Gender = .unknown, party: Party = .unknown, text: String? = nil) {
        self.userIdentifier = nil
        self.gender = gender
        self.party = party
        self.text = text
    }
    
    static func with(userID identifier: String) -> UserTag? {
        return Container.shared.user(with: identifier)
    }
}
