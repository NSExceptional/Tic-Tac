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
        var description: String {
            switch self {
                case .unknown:
                    return "___"
                case .male:
                    return "guy"
                case .female:
                    return "girl"
            }
        }
    }
    
    enum Party: String, Codable {
        case unknown = ""
        case right = "🐘"
        case left = "🧠"
        
        var string: String { self.rawValue }
        var description: String {
            switch self {
                
                case .unknown:
                    return "_____"
                case .right:
                    return "conservative"
                case .left:
                    return "progressive"
            }
        }
    }
    
    private static var random = SystemRandomNumberGenerator()
    
    let gender: Gender
    let party: Party
    let text: String?
    private(set) var pastEmojis: String?
    
    lazy var detailText: String = self.party.string + " " + self.gender.string
    lazy var longDescription: String = """
        \(party.description) \(gender.description)
        \(self.text ?? "No tags yet")
        Known emojis: \(pastEmojis ?? "none")
    """
    
    init(gender: Gender? = .unknown, party: Party? = .unknown, text: String? = nil, emoji: String? = nil) {
        self.id = nil
        self.gender = gender ?? .unknown
        self.party = party ?? .unknown
        self.text = text
        self.pastEmojis = emoji
    }
    
    static func with(userID identifier: String) -> UserTag? {
        return Container.shared.user(with: identifier)
    }
    
    func trackEmoji(_ emoji: String?) {
        guard let pastEmojis = self.pastEmojis else {
            return self.pastEmojis = emoji
        }
        
        guard let emoji = emoji else { return }
        
        if !pastEmojis.contains(emoji) {
            self.pastEmojis = "\(emoji)\(pastEmojis)"
        }
        
        if self.id != nil {
            try! Container.shared.update(user: self)
        }
    }
}
