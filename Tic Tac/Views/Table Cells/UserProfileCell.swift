//
//  UserProfileCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 2/3/23.
//

import UIKit
import YakKit

class UserProfileCell: AutoLayoutCell, ConfigurableCell {
    
    typealias Model = YYUser
    
    private let emojiView: UserEmojiView = .large()
    private let karmaLabel: UILabel = .init(textStyle: .headline)
    private let handleLabel: UILabel = .init(textStyle: .subheadline)
    
    // MARK: Overrides
    
    override var views: [UIView] { [emojiView, karmaLabel, handleLabel] }
    
    override func makeConstraints() {
        self.emojiView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.leading.bottom.equalToSuperview().inset(UIEdgeInsets(vertical: 10, horizontal: 16))
        }
        
        self.karmaLabel.snp.makeConstraints { make in
            make.leading.equalTo(emojiView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(emojiView.snp.centerY).offset(-3)
        }
        
        self.handleLabel.snp.makeConstraints { make in
            make.leading.equalTo(emojiView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(emojiView.snp.centerY).offset(3)
        }
    }
    
    func configure(with model: Model, context: YakContext) -> Self {
        self.textLabel?.text = String(model.karma)
        self.detailTextLabel?.text = model.handle ?? "no handle"
        return self
    }
}
