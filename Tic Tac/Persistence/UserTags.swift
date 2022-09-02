//
//  UserTags.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/23/22.
//

import YakKit

class UserTag {
    enum Gender {
        case unknown, m, f
        
        var string: String {
            switch self {
                case .unknown:
                    return ""
                case .m:
                    return "👱🏻‍♀️"
                case .f:
                    return "👦🏻"
            }
        }
    }
    
    enum Party {
        case unknown, right, left
        
        var string: String {
            switch self {
                case .unknown:
                    return ""
                case .right:
                    return "🐘"
                case .left:
                    return "🧠"
            }
        }
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
            let gender: Gender = Self.random.next().isMultiple(of: 2) ? .f : .unknown
            self.init(gender: gender, party: party, text: "user tag here")
        } else {
            return nil
        }
    }
}
