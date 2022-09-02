//
//  CommentsHeaderView.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/26/22.
//

import UIKit
import YakKit
import SnapKit

class CommentsHeaderView: AutoLayoutView {
    lazy private(set) var yakView = YakView(layout: .expanded)
    private lazy var commentButton = UIButton(type: .system)
    private lazy var scrollDownButton = UIButton(type: .system)
    
    private var commentButtonAction: UIAction? = nil
    private var scrollDownButtonAction: UIAction? = nil
    
    override var views: [UIView] { [yakView, scrollDownButton, commentButton] }
    
    override init() {
        super.init(frame: UIScreen.main.bounds)
    }
    
    static func withCommentHandler(_ handler: @escaping () -> Void) -> CommentsHeaderView {
        let header = CommentsHeaderView()
        header.commentButtonAction(handler)
        return header
    }
    
    override func setup(_ frame: CGRect) {
        super.setup(frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.commentButton.setTitle("Add Comment", for: .normal)
        self.scrollDownButton.setTitle("Scroll to End", for: .normal)
        
        self.yakView.title.font = .preferredFont(forTextStyle: .headline)
    }
    
    override func makeConstraints() {
        let space: CGFloat = 8
        let edges = UIEdgeInsets(vertical: 10, horizontal: 15)
        
        yakView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        scrollDownButton.snp.makeConstraints { make in
            make.width.equalTo(commentButton)
            make.top.equalTo(yakView.snp.bottom).offset(space)
            make.trailing.equalTo(yakView.snp.centerX).offset(-20)
            make.bottom.equalToSuperview().inset(edges)
        }
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(yakView.snp.bottom).offset(space)
            make.leading.equalTo(yakView.snp.centerX).offset(20)
            make.bottom.equalToSuperview().inset(edges)
        }
        
        self.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
    
    @discardableResult
    func configure(with yak: YYYak?, context: YakContext) -> CommentsHeaderView {
        self.yakView.configure(with: yak, context: context)
        return self
    }
    
    @discardableResult
    func commentButtonAction(_ handler: @escaping () -> Void) -> CommentsHeaderView {
        if self.commentButtonAction != nil {
            self.commentButton.removeAction(self.commentButtonAction!, for: .touchUpInside)
        }
        
        // I fucking hate that I have to fucking store this dumb fucking action
        // so I can remove it when it needs to change. FUCK
        self.commentButtonAction = UIAction { _ in handler() }
        self.commentButton.addAction(self.commentButtonAction!, for: .touchUpInside)
        
        return self
    }
    
    func scrollDownButtonAction(_ handler: @escaping () -> Void) -> CommentsHeaderView {
        if self.scrollDownButtonAction != nil {
            self.scrollDownButton.removeAction(self.scrollDownButtonAction!, for: .touchUpInside)
        }
        
        // I fucking hate that I have to fucking store this dumb fucking action
        // so I can remove it when it needs to change. FUCK
        self.scrollDownButtonAction = UIAction { _ in handler() }
        self.scrollDownButton.addAction(self.scrollDownButtonAction!, for: .touchUpInside)
        
        return self
    }
}
