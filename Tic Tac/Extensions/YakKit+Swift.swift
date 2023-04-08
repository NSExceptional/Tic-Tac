//
//  YakKit+Swift.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import Foundation
import YakKit

typealias Page<T> = (content: [T], cursor: String?)
typealias Callback<T> = (Result<T, Error>) -> Void

extension YYClient {
    public enum Feed: String {
        public enum Sort: String {
            case new = "NEW", hot = "HOT", top = "TOP"
            static var all: [Sort] { [.new, .hot, .top] }
        }
        
        case local = "LOCAL", nationwide = "NATIONWIDE"
        static var all: [Feed] { [.local, .nationwide] }
    }
    
    private func convertToResult<T>(_ array: [Any]?, _ error: Error?) -> Result<[T], Error> {
        switch (array, error) {
            case (.some(let array), nil):
                return .success(array as! [T])
            case (nil, .some(let error)):
                return .failure(error)
            default:
                return .failure(self.nullResponse)
        }
    }
    
    private func convertToResult<T, E>(page: ([E]?, String?), _ error: Error?) -> Result<T, Error> {
        switch (page.0, error) {
            case (.some(_), nil):
                return .success(page as! T)
            case (nil, .some(let error)):
                return .failure(error)
            default:
                return .failure(self.nullResponse)
        }
    }
    
    private func convertToResult<T>(_ thing: Any?, _ error: Error?) -> Result<T, Error> {
        switch (thing, error) {
            case (.some(let thing), nil):
                return .success(thing as! T)
            case (nil, .some(let error)):
                return .failure(error)
            default:
                return .failure(self.nullResponse)
        }
    }
    
    func getMyRecentYaks(after yak: String? = nil, completion: @escaping Callback<Page<YYYak>>) {
        self.objc_getMyRecentYaks(after: yak) { (a, c, e) in
            completion(self.convertToResult(page: (a, c), e))
        }
    }
    
    func getMyComments(after comment: String? = nil, completion: @escaping Callback<Page<YYComment>>) {
        self.objc_getMyRecentReplies(after: comment) { (a, c, e) in
            completion(self.convertToResult(page: (a, c), e))
        }
    }
    
    func getLocalYaks(after yak: String? = nil, sort: Feed.Sort = .new, completion: @escaping Callback<Page<YYYak>>) {
        switch sort {
            case .new:
                self.getLocalNewYaks(after: yak, completion: completion)
            case .hot:
                self.getLocalHotYaks(after: yak, completion: completion)
            case .top:
                self.getLocalTopYaks(after: yak, completion: completion)
        }
    }
    
    func getLocalNewYaks(after yak: String? = nil, completion: @escaping Callback<Page<YYYak>>) {
        self.objc_getLocalYaks(after: yak) { (a, c, e) in
            completion(self.convertToResult(page: (a, c), e))
        }
    }
    
    func getLocalHotYaks(after yak: String? = nil, completion: @escaping Callback<Page<YYYak>>) {
        self.objc_getLocalHotYaks(after: yak) { (a, c, e) in
            completion(self.convertToResult(page: (a, c), e))
        }
    }
    
    func getLocalTopYaks(after yak: String? = nil, completion: @escaping Callback<Page<YYYak>>) {
        self.objc_getLocalTopYaks(after: yak) { (a, c, e) in
            completion(self.convertToResult(page: (a, c), e))
        }
    }
    
    func getYak(from notification: YYNotification, completion: @escaping Callback<YYYak>) {
        self.objc_getYak(from: notification) { (thing, error) in
            completion(self.convertToResult(thing, error))
        }
    }
    
    func post(yak title: String, anonymously: Bool = true, completion: @escaping Callback<YYYak>) {
        self.objc_postYak(title, anonymously) { obj, error in
            completion(self.convertToResult(obj, error))
        }
    }
    
    func post(comment: String, to yak: YYYak, completion: @escaping Callback<YYComment>) {
        self.objc_postComment(comment, to: yak) { obj, error in
            completion(self.convertToResult(obj, error))
        }
    }
}

extension YYClient {
    func getNotifications(after notif: String? = nil, completion: @escaping Callback<Page<YYNotification>>) {
        self.objc_getNotifications(after: notif) { (notifs, cursor, error) in
            completion(self.convertToResult(page: (notifs, cursor), error))
        }
    }
}

extension YYClient {
    func getComments(for yak: YYYak, after comment: String? = nil, completion: @escaping Callback<Page<YYComment>>) {
        self.objc_getComments(for: yak, after: comment) { (comments, cursor, error) in
            completion(self.convertToResult(page: (comments, cursor), error))
        }
    }
}

extension YYClient {
    func adjustVote(on votable: YYVotable, set status: YYVoteStatus, _ score: Int,
                    _ callback: @escaping (YYVotable, Error?) -> Void) {
        let ogScore = votable.score
        let ogStatus = votable.voteStatus
        votable.score = score
        votable.voteStatus = status
        
        let undoVote = {
            votable.score = ogScore
            votable.voteStatus = ogStatus
        }
        
        // Undo the vote if it fails and pass it back to the caller
        let callbackWrapper: YYErrorBlock = { error in
            if error != nil {
                undoVote()
            }
            
            callback(votable, error)
        }
        
        switch status {
            case .upvoted:
                self.upvote(votable, completion: callbackWrapper)
            case .downvoted:
                self.downvote(votable, completion: callbackWrapper)
            default:
                self.removeVote(ogStatus, from: votable, completion: callbackWrapper)
        }
    }
}

extension YYClient {
    typealias CurrentUserSubscription = SubscriptionStore.Subscription<YYUser>
    private static let currentUserObservers = UnkeyedSubscriptionStore<YYUser>()
    private static var observingCurrentUser = false
    
    static func observeCurrentUser(_ subscription: @escaping CurrentUserSubscription) {
        if !observingCurrentUser {
            NotificationCenter.default.observe(.yyDidUpdateUser) { (user: YYUser) in
                notifyCurrentUserObservers(of: user)
            }
            observingCurrentUser = true
        }
        
        currentUserObservers.add(subscription)
    }
    
    private static func notifyCurrentUserObservers(of user: YYUser) {
        currentUserObservers.notifyAll(of: user)
    }
}

extension YYVotable {
    fileprivate static let ageFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.day, .hour, .minute]
        return f
    }()
    
    private static let measurementFormatter: MeasurementFormatter = {
        let f = MeasurementFormatter()
        f.numberFormatter.maximumFractionDigits = 1
        return f
    }()
    
    var gradient: (String, String) {
        if let color = self.colorHex {
            if let color2 = self.colorSecondaryHex {
                return (color, color2)
            }
            
            return (color, color)
        }
        
        return ("", "")
    }
    
    var age: String {
        return Self.ageFormatter.string(from: -self.created.timeIntervalSinceNow)!
    }
    
    var voteColor: UIColor? {
        switch self.voteStatus {
            case .downvoted:
                return .systemIndigo
            case .upvoted:
                return .systemOrange
            default:
                return nil
        }
    }
    
    var activityColor: UIColor? {
        guard let yak = self as? YYYak, yak.replyCount > 1 else {
            return nil
        }
        
        let percentHot = CGFloat(yak.replyCount) / 12
        let startingYellow = UIColor.systemYellow.withAlphaComponent(0.5)
        return UIColor(interpolate: percentHot, from: startingYellow, to: .systemRed)
    }
    
    func distance(from location: CLLocation?) -> String? {
        guard let location = location else { return nil }
        let meters = self.location.distance(from: location)
        let converter = Measurement(value: meters, unit: UnitLength.meters)
        let miles = converter.converted(to: .miles)
        return Self.measurementFormatter.string(from: miles)
    }
    
    private func metadataComponents(_ client: YYClient, _ includeScore: Bool) -> [StringBuilder.Component] {
        let shared: [StringBuilder.Component] = [
            .count(self.score, "point", exclude: !includeScore), .dot,
            .text(self.age), .dot,
            .text(self.distance(from: client.location)), .dot,
        ]
        
        switch self {
            case is YYYak:
                let yak = self as! YYYak
                return shared + [
                    .count(yak.replyCount, "comment"), .dot,
                    .text(yak.anonymous ? "🔍" : nil), .dot,
                ]
            default:
                return shared
        }
    }
    
    private func fancyMetadataComponents(_ client: YYClient, _ includeScore: Bool) -> [StringBuilder.Component] {
        let isOP = (self as? YYComment)?.isOP ?? false
        let voteColor = self.voteColor
        let commentsColor = self.activityColor
        let voteIcon = self.score >= 0 ? "arrow.up" : "arrow.down"
        let shared: [StringBuilder.Component] = [
            // Score
            .symbol(voteIcon, voteColor, exclude: !includeScore),
            .colored(.leadingSpace(.count(self.score)), voteColor, exclude: !includeScore),
            
            // OP indicator
            .attrText("OP", [
                .font: UIFont.isOP, .foregroundColor: UIColor.systemPink, .strokeWidth: -2
            ], exclude: !isOP),
            // Age
            .symbol("clock"), .leadingSpace(.text(self.age)),
            // Distance
            .symbol("map"), .leadingSpace(.text(self.distance(from: client.location))),
        ]
        
        switch self {
            case is YYYak:
                let yak = self as! YYYak
                return shared + [
                    .symbol("message", commentsColor),
                    .colored(.leadingSpace(.count(yak.replyCount)), commentsColor),
                    .symbol(yak.anonymous ? "eye.slash" : nil),
                ]
            default:
                return shared
        }
    }
    
    /// Looks like: 2h • 5 mi
    func metadataString(_ client: YYClient, includeScore: Bool = true) -> String {
        return StringBuilder(components: self.metadataComponents(client, includeScore)).string
    }
    
    /// Uses SF Symbols instead of words and separators
    func metadataAttributedString(_ client: YYClient, includeScore: Bool = true) -> NSAttributedString {
        var builder = StringBuilder(components: self.fancyMetadataComponents(client, includeScore))
        // Space out the components more
        builder.spaceWidth = 3
        return builder.attributedString
    }
}

extension YYVotable {
    func scoreAdjusted(for newStatus: YYVoteStatus) -> Int {
        guard self.voteStatus != newStatus else {
            return self.score
        }
        
        switch self.voteStatus {
            case .upvoted:
                switch newStatus {
                    case .downvoted:
                        return self.score - 2
                    default:
                        return self.score - 1
                }
            case .downvoted:
                switch newStatus {
                    case .upvoted:
                        return self.score + 2
                    default:
                        return self.score + 1
                }
            default:
                switch newStatus {
                    case .upvoted:
                        return self.score + 1
                    case .downvoted:
                        return self.score - 1
                    default:
                        fatalError("Unreachable")
                }
        }
    }
}

extension YYNotification {
    var age: String {
        return YYVotable.ageFormatter.string(from: -self.created.timeIntervalSinceNow)!
    }
}
