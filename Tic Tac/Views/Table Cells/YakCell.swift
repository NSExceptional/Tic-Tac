//
//  YakCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import YakKit

class YakCell: AutoLayoutCell {
    let yakView: YakView = .init()
    override var views: [UIView] { [yakView] }
    
    override func makeConstraints() {
        yakView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable, client: YYClient = .current) -> YakCell {
        self.yakView.configure(with: votable, client: client)
        return self
    }
    
    @discardableResult
    func handleVoteError(_ handler: @escaping (Error) -> Void) -> YakCell {
        self.yakView.voteErrorHandler = handler
        return self
    }
}

class YakView: AutoLayoutView {
    let title = UILabel(textStyle: .headline).multiline()
    let metadata = UILabel(textStyle: .footnote)
    let emoji = UserEmojiView.small()
    let voteCounter = VoteControl()
    
    var voteErrorHandler: ((Error) -> Void)?
    
    override var views: [UIView] { [title, metadata, emoji, voteCounter] }
    
    override func makeConstraints() {
        let space: CGFloat = 8
        let edges = UIEdgeInsets(vertical: 8, horizontal: 15)
        
        emoji.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(edges)
        }
        metadata.snp.makeConstraints { make in
            make.centerY.equalTo(emoji)
            make.leading.equalTo(emoji.snp.trailing).offset(space)
        }
        title.snp.makeConstraints { make in
            make.top.equalTo(emoji.snp.bottom).offset(space)
            make.leading.equalToSuperview().inset(edges)
            make.bottom.lessThanOrEqualToSuperview().inset(edges.bottom + 5)
        }
        voteCounter.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(edges)
            make.leading.greaterThanOrEqualTo(metadata.snp.trailing).offset(space)
            make.leading.greaterThanOrEqualTo(title.snp.trailing).offset(space)
            make.bottom.lessThanOrEqualToSuperview().inset(edges)
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable, client: YYClient = .current) -> YakView {
        self.emoji.set(emoji: votable.emoji, colors: votable.gradient)
        self.title.text = votable.text
        self.metadata.text = votable.metadataString(client)
        
        self.voteCounter.setVote(votable.voteStatus, score: votable.score)
        self.voteCounter.onVoteStatusChange = { status, score in
            client.adjustVote(on: votable, set: status, score) { (votable, error) in
                // Reset vote counter / status
                self.voteCounter.setVote(votable.voteStatus, score: votable.score)
                // Pass error up the chain
                if let error = error {
                    self.voteErrorHandler?(error)
                }
            }
        }

        return self
    }
    
    @discardableResult
    func handleVoteError(_ handler: @escaping (Error) -> Void) -> YakView {
        self.voteErrorHandler = handler
        return self
    }
}

