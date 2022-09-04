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
    
    init(userID: String? = nil, gender: Gender = .unknown, party: Party = .unknown, text: String? = nil) {
        self.userIdentifier = userID
        self.gender = gender
        self.party = party
        self.text = text
    }
    
    convenience init?(user: YYUser) {
        self.init(userID: user.identifier)
    }
    
    convenience init?(userID: String) {
        if Self.random.next().isMultiple(of: 2) {
            let party: Party = Self.random.next().isMultiple(of: 2) ? .right : .unknown
            let gender: Gender = Self.random.next().isMultiple(of: 2) ? .female : .unknown
            self.init(gender: gender, party: party, text: "user tag here")
        } else {
            return nil
        }
    }
}
