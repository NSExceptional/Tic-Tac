//
//  TicTacTests.swift
//  TicTacTests
//
//  Created by Tanner Bennett on 6/26/22.
//

import XCTest
import YakKit
@testable import Tic_Tac

class PreviewTests: XCTestCase {
    func testPreviewDataDoesntCrash() {
        _ = PreviewData.yak()
    }
}

class TicTacTests: XCTestCase {
    let vote = VoteControl()
    
    private func assert(status: YYVoteStatus, score: Int) {
        XCTAssertEqual(self.vote.score, score)
        XCTAssertEqual(self.vote.status, status)
        
        assertArrowColors(status)
    }
    
    private func assertArrowColors(_ status: YYVoteStatus) {
        switch status {
            case .upvoted:
                XCTAssertEqual(vote.upvoteButton.tintColor, .systemOrange)
                XCTAssertEqual(vote.downvoteButton.tintColor, .white)
            case .downvoted:
                XCTAssertEqual(vote.upvoteButton.tintColor, .white)
                XCTAssertEqual(vote.downvoteButton.tintColor, .systemIndigo)
            default:
                XCTAssertEqual(vote.upvoteButton.tintColor, .white)
                XCTAssertEqual(vote.downvoteButton.tintColor, .white)
        }
    }
    
    func testVoteControl() {
        assert(status: .none, score: 0)
        
        vote.setVote(.none, score: 1)
        assert(status: .none, score: 1)
        
        vote.setVote(.none, score: -3)
        assert(status: .none, score: -3)
        
        vote.simulateVote(.downvoted)
        assert(status: .downvoted, score: -4)
        
        vote.setVote(.none, score: 1)
        assert(status: .none, score: 1)
        
        vote.simulateVote(.upvoted)
        assert(status: .upvoted, score: 2)
        
        vote.simulateVote(.downvoted)
        assert(status: .downvoted, score: 0)
        
        vote.simulateVote(.downvoted)
        assert(status: .none, score: 1)
    }
    
    struct Notification: Hashable, Equatable {
        let id: Int
        let postID: Int
        let age: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.postID)
        }
        
        static func == (lhs: Notification, rhs: Notification) -> Bool {
            return lhs.postID == rhs.postID
        }
    }
    
    func testAssumptionsAboutUniquing() {
        let notifs: [Notification] = [
            .init(id: 9, postID: 0xdead, age: "1m"),
            .init(id: 8, postID: 0xdead, age: "2m"),
            .init(id: 7, postID: 0xdead, age: "5m"),
            .init(id: 6, postID: 0xbabe, age: "20m"),
            .init(id: 5, postID: 0xbabe, age: "43m"),
            .init(id: 4, postID: 0xbabe, age: "11h"),
        ]
        
        let filtered = notifs.uniqued()
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0], notifs[0])
        XCTAssertEqual(filtered[1], notifs[3])
    }
    
    func testEffect() {
        var loading = false
        
        @Effect var complete = false
        $complete.didSet = {
            loading = !complete
        }
        
        XCTAssertTrue(loading)
        
        complete = true
        
        XCTAssertFalse(loading)
    }
    
    func testPreviewData() {
        XCTAssertNoThrow(PreviewData.yak())
    }
}
