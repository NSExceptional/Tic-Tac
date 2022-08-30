//
//  SpinnerFooterView.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/30/22.
//

import UIKit
import SnapKit

class SpinnerFooterView: AutoLayoutView {
    private let spinner = UIActivityIndicatorView(style: .large)
    override var views: [UIView] { [spinner] }
    
    override init(frame: CGRect) {
        _size = .square(frame.size.height)
        super.init(frame: frame)
    }
    
    override func setup(_ frame: CGRect) {
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
        self.spinner.setContentHuggingPriority(.required, for: .vertical)
        self.spinner.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            self.spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    let _size: CGSize
    override var intrinsicContentSize: CGSize { _size }
    
    override func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        return .init(width: targetSize.width, height: _size.height)
    }
    
    func start() {
        self.spinner.startAnimating()
    }
    
    func stop() {
        self.spinner.stopAnimating()
    }
}

