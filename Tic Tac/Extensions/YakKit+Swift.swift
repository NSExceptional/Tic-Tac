//
//  YakKit+Swift.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import Foundation
import YakKit

extension YYClient {
    private func convertToResult<T>(_ array: [Any]?, _ error: Error?) -> Result<[T], Error> {
        switch (array, error) {
            case (.some(let array), nil):
                return .success(array as! [T])
            case (nil, .some(let error)):
                return .failure(error)
            default:
                fatalError()
        }
    }
    
    private func convertToResult<T>(_ thing: Any?, _ error: Error?) -> Result<T, Error> {
        switch (thing, error) {
            case (.some(let thing), nil):
                return .success(thing as! T)
            case (nil, .some(let error)):
                return .failure(error)
            default:
                fatalError()
        }
    }
    
    func getLocalYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
    
    func getLocalHotYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalHotYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
    
    func getLocalTopYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalTopYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
    
    func getYak(from notification: YYNotification, completion: @escaping (Result<YYYak, Error>) -> Void) {
        self.objc_getYak(from: notification) { (thing, error) in
            completion(self.convertToResult(thing, error))
        }
    }
}

extension YYClient {
    func getNotifications(after notif: YYNotification? = nil, completion: @escaping (Result<[YYNotification], Error>) -> Void) {
        self.objc_getNotifications(after: notif) { (notifs, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(notifs as! [YYNotification]))
            }
        }
    }
}

extension YYClient {
    func getComments(for yak: YYYak, completion: @escaping (Result<[YYComment], Error>) -> Void) {
        self.objc_getComments(for: yak) { (comments, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(comments as! [YYComment]))
            }
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

extension YYVotable {
    private static let ageFormatter: DateComponentsFormatter = {
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
    
    func distance(from location: CLLocation?) -> String? {
        guard let location = location else { return nil }
        let meters = self.location.distance(from: location)
        let converter = Measurement(value: meters, unit: UnitLength.meters)
        let miles = converter.converted(to: .miles)
        return Self.measurementFormatter.string(from: miles)
    }
    
    private func metadataComponents(_ client: YYClient) -> [StringBuilder.Component] {
        let shared: [StringBuilder.Component] = [
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
    
    func metadataString(_ client: YYClient) -> String {
        return StringBuilder(components: self.metadataComponents(client)).string
    }
}
