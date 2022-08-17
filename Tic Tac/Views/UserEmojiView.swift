//
//  UserEmojiView.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/24/22.
//

import UIKit
import SnapKit

class UserEmojiView: AutoLayoutView {
    static func small() -> UserEmojiView {
        return .init(frame: .square(25))
    }
    
    static func medium() -> UserEmojiView {
        return .init(frame: .square(36))
    }
    
    static func large() -> UserEmojiView {
        return .init(frame: .square(50))
    }
    
    func set(emoji: String?, colors: (String, String)) {
        self.label.text = emoji ?? "?"
        self.gradient.colors = [colors.0, colors.1].map { UIColor(hex: $0).cgColor }
    }
    
    func set(emoji: String?, uicolor: UIColor) {
        self.label.text = emoji ?? "?"
        self.gradient.colors = [uicolor, uicolor].map { $0.cgColor }
    }
    
    private var label = UILabel()
    override var views: [UIView] { [label] }
    
    override init(frame: CGRect) {
        _size = frame.size
        super.init(frame: frame)
    }
    
    override func setup(_ frame: CGRect) {
        self.sizeCorners()
        
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.label.setContentHuggingPriority(.required, for: .vertical)
        self.label.setContentHuggingPriority(.required, for: .horizontal)
        
        self.label.text = "?"
        self.label.textAlignment = .center
        self.label.font = self.label.font.withSize(self.frame.width * 0.6)
        self.gradient.colors = [UIColor.white, UIColor.white].map(\.cgColor)
        
        self.label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func sizeCorners() {
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    override var frame: CGRect {
        didSet {
            self.sizeCorners()
        }
    }
    
    var gradient: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    let _size: CGSize
    override var intrinsicContentSize: CGSize { _size }
}
