//
//  UserEmojiPickerView.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 2/3/23.
//

import UIKit

struct UserEmoji {
    let emoji: String
    let color1, color2: String
    
    var colors: (String, String) {
        (color1, color2)
    }
    
    init(_ emoji: String, _ color1: String, _ color2: String? = nil) {
        self.emoji = emoji
        self.color1 = color1
        self.color2 = color2 ?? color1
    }
}

class UserEmojiPickerView: UICollectionView, UICollectionViewDataSource {
    
    private class EmojiCell: UICollectionViewCell {
        private let emojiView = UserEmojiView.medium()
        
        var emoji: UserEmoji = .init("+", "") {
            willSet {
                self.emojiView.set(emoji: newValue.emoji, colors: newValue.colors)
            }
        }
        
        override var reuseIdentifier: String? { "EmojiCell" }
        override var intrinsicContentSize: CGSize { self.emojiView.intrinsicContentSize }
        
        required init?(coder: NSCoder) { fatalError() }
        override init(frame: CGRect) {
            super.init(frame: .init(origin: frame.origin, size: self.emojiView.frame.size))
            self.contentView.addSubview(self.emojiView)
            
            self.layer.cornerRadius = self.emojiView.layer.cornerRadius
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
            self.layer.borderWidth = 1
        }
    }
    
    private let emojis: [UserEmoji] = [
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
        .init("🍿", "#5857FF"), .init("🖕🏻", "#000000"),
    ]
    
//    private lazy var layout = {
//        let layout = UICollectionViewFlowLayout()
//        
//        layout.sectionInset = .zero
//        layout.itemSize = .square(UserEmojiView.Constants.mediumSize)
//        
//        layout.minimumInteritemSpacing = 5
//        layout.minimumLineSpacing = 5
//        
//        return layout
//    }()
    
//    override var frame: CGRect {
//        didSet {
//            let spacing = self.frame.width
//            self.layout.minimumInteritemSpacing = UserEmojiPickerView.spacing
//            self.layout.minimumLineSpacing = UserEmojiPickerView.spacing
//        }
//    }
    
    convenience init(_ frame: CGRect = .zero) {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = .zero
        layout.itemSize = .square(UserEmojiView.Constants.mediumSize)
        
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
//        self.init()
        self.init(frame: frame, collectionViewLayout: layout)
        
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.register(cell: EmojiCell.self)
        self.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojis.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EmojiCell = self.dequeueCell(for: indexPath)
        
        if indexPath.row < self.emojis.count {
            cell.emoji = self.emojis[indexPath.row]
        }
        else {
            cell.emoji = .init("➕", "#FFFFFF")
        }
        
        return cell
    }
}
