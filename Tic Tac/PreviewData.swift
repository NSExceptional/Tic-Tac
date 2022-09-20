//
//  PreviewData.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/29/22.
//

import YakKit

extension YYVoteStatus {
    var string: String {
        switch self {
            case .upvoted:
                return "UP"
            case .downvoted:
                return "DOWN"
            default:
                return "NONE"
        }
    }
}

extension Date {
    static func beforeNow(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let offset = (days * day) + (hours * hour) + (minutes * minute)
        
        return Date().advanced(by: TimeInterval(-offset))
    }
}

public enum PreviewData {
    static func yak(
        title: String = "Freshman r ruining Yik Yak fr",
        emoji: String = "🎤",
        colors: [String] = ["#8483FF", "#5857FF"],
        
        area: String? = "Baylor University",
        tag: String? = nil,
        
        vote: YYVoteStatus = .none,
        score: Int = 5,
        date: Date = .beforeNow(hours: 1, minutes: 23),
        location: CLLocationCoordinate2D = .init(latitude: 32.8585, longitude: -96.7625),
        commentCount: Int = 42,
        isMine: Bool = false,
        anonymous: Bool = true
    ) -> YYYak {
        try! .init(dictionary: [
            "id": "WWFrOMabcdefg",
            "interestAreas": area == nil ? [] : [area],
            "userEmoji": emoji,
            "myVote": vote.string,
            "voteCount": score,
            "isClaimed": false,
            "userColor": colors[0],
            "secondaryUserColor": colors[1],
            "userId": "abcdefg",
            "text": title,
            "commentCount": commentCount,
            "point": ["coordinates": [location.longitude, location.latitude]],
            "isMine": isMine,
            "createdAt": YYThing.dateFormatter.string(from: date),
            "isIncognito": anonymous,
        ])
    }
    
    static func context(origin: YakDataOrigin = .organic) -> YakContext {
        class PreviewHost: ContextualHost {
            var presentingViewController: UIViewController?
            var navigationController: UINavigationController? { nil }
            
            func dismissSelf() { }
            func dismiss(animated flag: Bool, completion: (() -> Void)?) { }
            func presentError(_ error: Error, title: String) { }
        }
        
        struct PreviewYakContext: YakContext {
            let host: ContextualHost = PreviewHost()
            let origin: YakDataOrigin
            let loading: Bool = false
        }
        
        return PreviewYakContext(origin: origin)
    }
}
