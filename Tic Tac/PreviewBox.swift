//
//  PreviewBox.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 2/25/23.
//

import Foundation

#if DEBUG
#if targetEnvironment(simulator)

class PreviewBox: AutoLayoutView {
    private let size: CGSize
    override var intrinsicContentSize: CGSize { self.size }
    
    private let child: UIView
    override var views: [UIView] { [self.child] }
    
    init(child: UIView, size: CGSize) {
        self.child = child
        self.size = size
        super.init(frame: CGRect(origin: .zero, size: size))
        
        self.backgroundColor = .systemBackground
    }
    
    override func setup(_ frame: CGRect) {
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .horizontal)
        
//        self.child.setContentHuggingPriority(.required, for: .vertical)
//        self.child.setContentHuggingPriority(.required, for: .horizontal)
        
        self.child.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


#endif
#endif
