//
//  TicTacTests.swift
//  TicTacTests
//
//  Created by Tanner Bennett on 6/26/22.
//

import XCTest
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
}
