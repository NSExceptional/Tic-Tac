//
//  YakCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import TBAlertController
import YakKit

class YakCell: AutoLayoutCell, ConfigurableCell {
    typealias Model = YYVotable
    
    class ChevronView: AutoLayoutView {
        let imageView: UIImageView = .init(image: .symbol("chevron.right", size: .small))
        override var views: [UIView] { [imageView] }
        
        override func setup(_ frame: CGRect) {
            imageView.tintColor = .secondaryLabel
            
            self.hugging(.required, axis: .horizontal)
            self.hugging(.required, axis: .vertical)
            self.expansion(.required, axis: .horizontal)
            self.expansion(.required, axis: .vertical)
        }
        
        override func makeConstraints() {
            self.imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(YakView.Layout.edges)
            }
        }
    }
    
    let yakView: YakView = .init(layout: .compact)
    let chevron: ChevronView = .init()
    private lazy var stack = UIStackView(arrangedSubviews: [yakView, chevron])
        .axis(.horizontal).alignment(.top).spacing(10).distribution(.equalSpacing)
    
    override var views: [UIView] { [stack] }
    
    override func makeConstraints() {
        self.stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable, context: YakContext) -> Self {
        self.yakView.configure(with: votable, context: context)
        
        self.chevron.isHidden = context.origin == .organic
        
        return self
    }
    
    /// For view controllers to display an error when voting fails
    @discardableResult
    func handleVoteError(_ handler: @escaping (Error) -> Void) -> YakCell {
        self.yakView.voteErrorHandler = handler
        return self
    }
    
    func adjustVote(on votable: YYVotable, _ newStatus: YYVoteStatus,
                    client: YYClient = .current, callback: @escaping (Error?) -> Void) {
        guard votable.voteStatus != newStatus else { return }
        let newScore = votable.scoreAdjusted(for: newStatus)
        self.yakView.adjustVote(on: votable, newStatus, newScore, callback: callback)
    }
}

class YakView: AutoLayoutView {
    enum Layout {
        case compact
        case expanded
        
        static let spacing: CGFloat = 8
        static let edges = UIEdgeInsets(vertical: 8, horizontal: 12)
        
        var showsVoteControl: Bool {
            return self == .expanded
        }
        
        var emojiUnderTitle: Bool {
            return self == .expanded
        }
        
        var scoreInMetadata: Bool {
            return !self.showsVoteControl
        }
    }
    
    let title = UILabel(textStyle: .body).multiline()
    let subtitle = UILabel(textStyle: .footnote).multiline().color(.secondaryLabel)
    let metadata = UILabel(textStyle: .footnote).color(.secondaryLabel)
    lazy var emoji: UserEmojiView = layout.showsVoteControl ? .small() : .medium()
    lazy var voteCounter: VoteControl? = self.layout.showsVoteControl ? .init() : nil
    lazy var underEmojiDetails = UILabel(textStyle: .footnote).color(self.tintColor).align(.center)
    
    private lazy var metadataRow = UIStackView(arrangedSubviews: [metadata])
        .hugging(.required, axis: .horizontal).axis(.horizontal).distribution(.fill).spacing(8)
    private lazy var labelStack = UIStackView(arrangedSubviews: [title, subtitle, metadataRow])
        .hugging(.required, axis: .horizontal).axis(.vertical).distribution(.equalSpacing).spacing(6)
    
    var voteErrorHandler: ((Error) -> Void)? = nil
    private var votableID: String? = nil
    private var deleteVotable: (() -> Void)?
    private let layout: YakView.Layout
    
    override var views: [UIView] {
        // Optionally include the vote counter based
        var views: [UIView] = [labelStack]
        if self.layout.showsVoteControl {
            views.append(voteCounter!)
        }
        
        // Put emoji where it belongs
        if self.layout.emojiUnderTitle {
            self.metadataRow.insertArrangedSubview(self.emoji, at: 0)
        }
        else {
            views += [self.emoji, self.underEmojiDetails]
        }
        
        return views
    }
    
    init(layout: YakView.Layout = .compact) {
        self.layout = layout
        
        super.init()
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
    }
    
    override func makeConstraints() {
        let space = Layout.spacing
        let edges = Layout.edges
        
        // Layout with vote counter:
        // ┌────────────────────────────────────────────────┐
        // │                                                │
        // │   Post title here                       ^      │
        // │             | 8                      5  |      │
        // │   (🧼)-+-2h 34m • 5 mi • 7 comments     v      │
        // │        8                                       │
        // └────────────────────────────────────────────────┘
        if self.layout.showsVoteControl {
            labelStack.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(edges.bottom + 5)
                make.leading.equalToSuperview().inset(edges)
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
                make.trailing.equalTo(voteCounter!.snp.leading).offset(-space)
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
        // │    ‾‾       | 8                                │
        // │    xy   ↑5 • 2h 34m • 5 mi • 7                 │
        // │                                                │
        // └────────────────────────────────────────────────┘
        else {
            emoji.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().inset(edges.vertical(offset: 2))
            }
            underEmojiDetails.snp.makeConstraints { make in
                make.top.equalTo(emoji.snp.bottom).offset(space)
                make.leading.equalToSuperview().inset(edges)
                make.bottom.lessThanOrEqualToSuperview().inset(edges)
            }
            labelStack.snp.makeConstraints { make in
                make.top.bottom.trailing.equalToSuperview().inset(edges)
                make.leading.equalTo(emoji.snp.trailing).offset(edges.left)
            }
        }
    }
    
    @discardableResult
    func configure(with votable: YYVotable?, context: YakContext) -> YakView {
        #if DEBUG
        self.model = votable
        #endif
        
        let client = context.client
        self.votableID = votable?.identifier
        
        // Clear all data if no votable given
        guard let votable = votable else {
            return self.configureEmpty(loading: context.loading)
        }
        
        let userTag = UserTag.with(userID: votable.authorIdentifier)
        
        self.emoji.set(emoji: votable.emoji, colors: votable.gradient)
        self.title.text = votable.text
        self.setSubtitles(tag: userTag, location: votable.locationName)
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
        
        if votable.isMine {
            self.deleteVotable = {
                switch votable {
                    case is YYYak:
                        client.delete(votable as! YYYak, completion: nil)
                    case is YYComment:
                        client.delete(votable as! YYComment, completion: nil)
                    default:
                        break
                }
            }
        }

        return self
    }
    
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .recognized else { return }
        
        if let deletion = self.deleteVotable {
            TBAlert.make { make in
                make.title("Delete Submission").message("Are you sure you want to delete this submission?")
                make.button("Dismiss").cancelStyle()
                make.button("Delete").destructiveStyle().handler { _ in
                    deletion()
                }
            }.show(from: UIApplication.rootViewController)
        }
    }
    
    private func setSubtitles(tag: UserTag?, location: String?) {
        self.subtitle.attributedText = StringBuilder(components: [
            .symbol("safari"), .leadingSpace(.text(location)),
            .separator(.space),
            .symbol("tag", self.tintColor, exclude: tag?.text == nil),
            .leadingSpace(.colored(.text(tag?.text), self.tintColor, exclude: tag == nil)),
        ]).attributedString
        
        self.subtitle.isHidden = tag?.text == nil && location == nil
        
        self.underEmojiDetails.text = tag?.detailText
    }
    
    private func updateMetadataText(with votable: YYVotable?, _ client: YYClient = .current) {
        self.metadata.attributedText = votable?.metadataAttributedString(
            client, includeScore: self.layout.scoreInMetadata
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
    
    private func configureEmpty(loading: Bool = false) -> YakView {
        if loading {
            self.emoji.set(emoji: " ", uicolor: .clear)
            self.title.text = "Loading…"
            self.metadata.text = "… … … …"
        }
        else {
            self.emoji.set(emoji: "⛔️", uicolor: .black)
            self.title.text = "[No title]"
            self.metadata.text = "[No information]"
        }
        
        self.emoji.alpha = 1
        self.voteCounter?.isEnabled = false
        self.voteCounter?.setVote(.none, score: 0)
        self.voteCounter?.onVoteStatusChange = { _, _ in }
        
        self.setSubtitles(tag: nil, location: nil)
        self.updateMetadataText(with: nil)
        
        return self
    }
    
    #if DEBUG
    private var model: YYVotable? = nil
    #endif
}

