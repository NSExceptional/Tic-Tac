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
    let yakView = YakView()
    let commentButton: UIButton = .init(type: .system)
    
    private var buttonAction: UIAction? = nil
    private var heightConstraint: SnapKit.Constraint?
    
    override var views: [UIView] { [yakView, commentButton] }
    
    override func setup(_ frame: CGRect) {
        super.setup(frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.commentButton.setTitle("Add Comment", for: .normal)
        
        self.yakView.title.font = .preferredFont(forTextStyle: .headline)
        
//        self.backgroundColor = .secondarySystemBackground
    }
    
    override func makeConstraints() {
        let space: CGFloat = 8
        let edges = UIEdgeInsets(vertical: 10, horizontal: 15)
        
        yakView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(yakView.snp.bottom).offset(space)
            make.centerX.equalTo(yakView)
            make.bottom.equalToSuperview().inset(edges)
        }
        
        self.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
    
    @discardableResult
    func configure(with yak: YYYak, client: YYClient = .current) -> CommentsHeaderView {
        self.yakView.configure(with: yak, client: client)
        return self
    }
    
    @discardableResult
    func buttonAction(_ handler: @escaping () -> Void) -> CommentsHeaderView {
        if self.buttonAction != nil {
            self.commentButton.removeAction(self.buttonAction!, for: .touchUpInside)
        }
        
        // I fucking hate that I have to fucking store this dumb fucking action
        // so I can remove it when it needs to change. FUCK
        self.buttonAction = UIAction(handler: unsafeBitCast(handler, to: UIActionHandler.self))
        self.commentButton.addAction(self.buttonAction!, for: .touchUpInside)
        
        return self
    }
}
