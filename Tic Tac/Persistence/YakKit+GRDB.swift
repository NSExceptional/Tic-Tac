//
//  YakKit+GRDB.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 9/3/22.
//

import YakKit

class YYStoredVotable: Entity {
    var id: String?
    
    let text: String
    let userId: String
    
    let emoji, userColor, secondaryUserColor: String?
    let createdAt: Date
    let voteCount: Int
    
    let locationName: String?
    let lat: Double
    let lng: Double
    
    init(from votable: YYVotable) {
        self.id = votable.identifier
        self.text = votable.text
        self.userId = votable.authorIdentifier
        
        self.emoji = votable.emoji
        self.userColor = votable.colorHex
        self.secondaryUserColor = votable.colorSecondaryHex
        self.createdAt = votable.created
        self.voteCount = votable.score
        
        self.locationName = votable.locationName
        self.lat = votable.location.coordinate.latitude
        self.lng = votable.location.coordinate.longitude
    }
    
    var dictionaryValue: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        var dict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        dict["point"] = ["coordinates": [dict["lat"], dict["lng"]]]
        
        return dict
    }
}

class YYStoredPost: YYStoredVotable {
    
}

class YYStoredComment: YYStoredVotable {
    var parentId: String?
}

extension YYVotable {
    convenience init(from storedVotable: YYStoredVotable) {
        self.init(dictionary: storedVotable.dictionaryValue)
    }
}
