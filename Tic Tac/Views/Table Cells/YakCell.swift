//
//  YakCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import YakKit

class YakCell: AutoLayoutCell, ConfigurableCell {
    typealias Model = YYVotable
    
    let yakView: YakView = .init(showVoteControl: false)
    override var views: [UIView] { [yakView] }
    
    override func makeConstraints() {
        yakView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable, client: YYClient = .current) -> Self {
        self.yakView.configure(with: votable, client: client)
        return self
    }
    
    /// For view controllers to display an error when voting fails
    @discardableResult
    func handleVoteError(_ handler: @escaping (Error) -> Void) -> YakCell {
        self.yakView.voteErrorHandler = handler
        return self
    }
    
//    func upvote(_ votable: YYVotable, client: YYClient = .current, callback: @escaping (Error?) -> Void) {
//        guard votable.voteStatus != .upvoted else { return }
//        self.yakView.adjustVote(on: votable, .upvoted, votable.score + 1, callback: callback)
//    }
//
//    func downvote(_ votable: YYVotable, client: YYClient = .current, callback: @escaping (Error?) -> Void) {
//        guard votable.voteStatus != .downvoted else { return }
//        self.yakView.adjustVote(on: votable, .downvoted, votable.score + 1, callback: callback)
//    }
//
//    func revokeVote(on votable: YYVotable, client: YYClient = .current, callback: @escaping (Error?) -> Void) {
//        guard votable.voteStatus != .none else { return }
//        let adjustment = votable.voteStatus == .upvoted ? -1 : 1
//        self.yakView.adjustVote(on: votable, .none, votable.score + adjustment, callback: callback)
//    }
    
    func adjustVote(on votable: YYVotable, _ newStatus: YYVoteStatus,
                    client: YYClient = .current, callback: @escaping (Error?) -> Void) {
        guard votable.voteStatus != newStatus else { return }
        let newScore = votable.scoreAdjusted(for: newStatus)
        self.yakView.adjustVote(on: votable, newStatus, newScore, callback: callback)
    }
}

class YakView: AutoLayoutView {
    let title = UILabel(textStyle: .body).multiline()
    let metadata = UILabel(textStyle: .footnote).color(.secondaryLabel)
    lazy var emoji: UserEmojiView = showsVoteControl ? .small() : .medium()
    lazy var voteCounter: VoteControl? = showsVoteControl ? .init() : nil
    
    var votableID: String? = nil
    var voteErrorHandler: ((Error) -> Void)? = nil
    
    private var showsVoteControl: Bool
    
    override var views: [UIView] {
        // Optionally include the vote counter based
        var views = [title, metadata, emoji]
        if showsVoteControl {
            views.append(voteCounter!)
        }
        
        return views
    }
    
    init(showVoteControl: Bool = false) {
        self.showsVoteControl = showVoteControl
        super.init()
    }
    
    override func makeConstraints() {
        let space: CGFloat = 8
        let edges = UIEdgeInsets(vertical: 10, horizontal: 15)
        
        // Layout with vote counter:
        // ┌────────────────────────────────────────────────┐
        // │                                                │
        // │   Post title here                       ^      │
        // │                                      5  |      │
        // │   (🧼) 2h 34m • 5 mi • 7 comments       v      │
        // │                                                │
        // └────────────────────────────────────────────────┘
        if self.showsVoteControl {
            title.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(edges.bottom + 5)
                make.leading.equalToSuperview().inset(edges)
                make.bottom.equalTo(emoji.snp.top).offset(-space)
                make.trailing.equalTo(voteCounter!.snp.leading).offset(-space)
            }
            emoji.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(edges)
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
            }
            metadata.snp.makeConstraints { make in
                make.centerY.equalTo(emoji)
                make.leading.equalTo(emoji.snp.trailing).offset(space)
                make.trailing.equalTo(title)
            }
            
            voteCounter?.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview().inset(edges)
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
            }
        }
        // Layout withOUT vote counter:
        // ┌────────────────────────────────────────────────┐
        // │    __                                          │
        // │  ( 🧼 ) Post title here                        │
        // │    ‾‾                                          │
        // │         ↑5 • 2h 34m • 5 mi • 7                 │
        // │                                                │
        // └────────────────────────────────────────────────┘
        else {
            emoji.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().inset(edges.vertical(12))
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
            }
            title.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(edges)
                make.leading.equalTo(emoji.snp.trailing).offset(edges.left)
                make.bottom.equalTo(metadata.snp.top).offset(-space)
                make.trailing.equalToSuperview().inset(edges)
            }
            metadata.snp.makeConstraints { make in
                make.leading.equalTo(title)
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
                make.trailing.equalTo(title)
            }
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable?, client: YYClient = .current) -> YakView {
        #if DEBUG
        self.model = votable
        #endif
        
        self.votableID = votable?.identifier
        
        // Clear all data if no votable given
        guard let votable = votable else {
            return self.configureEmpty()
        }
        
        self.emoji.set(emoji: votable.emoji, colors: votable.gradient)
        self.title.text = votable.text
        self.updateMetadataText(with: votable, client)
        
        self.emoji.alpha = votable.anonymous ? 0.8 : 1
        
        self.voteCounter?.isEnabled = true
        self.voteCounter?.setVote(votable.voteStatus, score: votable.score)
        self.voteCounter?.onVoteStatusChange = { status, score in
            client.adjustVote(on: votable, set: status, score) { (votable, error) in
                // Reset vote counter / status
                self.voteCounter?.setVote(votable.voteStatus, score: votable.score)
                // Pass error up the chain
                if let error = error {
                    self.voteErrorHandler?(error)
                }
            }
        }

        return self
    }
    
    private func updateMetadataText(with votable: YYVotable, _ client: YYClient = .current) {
        self.metadata.attributedText = votable.metadataAttributedString(
            // Only show the score if the vote control is hidden
            client, includeScore: !self.showsVoteControl
        )
    }
    
    func adjustVote(on votable: YYVotable, _ status: YYVoteStatus, _ newScore: Int,
                    client: YYClient = .current, callback: @escaping (Error?) -> Void) {
        client.adjustVote(on: votable, set: status, newScore) { (votable, error) in
            // Reset vote counter / status on error if we're still on the same cell
            // TODO: use a notification and observer?
            if self.votableID == votable.identifier {
                self.voteCounter?.setVote(votable.voteStatus, score: votable.score)
                self.updateMetadataText(with: votable, client)
            }
            
            // Pass error up the chain
            if let error = error {
                self.voteErrorHandler?(error)
            }
            
            callback(error)
        }
    }
    
    @discardableResult
    func handleVoteError(_ handler: @escaping (Error) -> Void) -> YakView {
        self.voteErrorHandler = handler
        return self
    }
    
    private func configureEmpty() -> YakView {
        self.emoji.set(emoji: "⛔️", uicolor: .black)
        self.title.text = "[No title]"
        self.metadata.text = "[No information]"
        self.emoji.alpha = 1
        
        self.voteCounter?.isEnabled = false
        self.voteCounter?.setVote(.none, score: 0)
        self.voteCounter?.onVoteStatusChange = { _, _ in }
        
        return self
    }
    
    #if DEBUG
    private var model: YYVotable? = nil
    #endif
}

