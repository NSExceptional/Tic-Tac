//
//  AutoLayout.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/26/22.
//

import UIKit

class AutoLayoutView: UIView {
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.views.forEach(self.addSubview(_:))
        self.views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        self.setup(frame)
    }
    
    override class var requiresConstraintBasedLayout: Bool { true }
    var views: [UIView] { [] }
    
    func makeConstraints() { }
    func setup(_ frame: CGRect) { }
    
    override func layoutSubviews() {
        self.makeConstraints()
        super.layoutSubviews()
    }
}

class AutoLayoutCell: BaseCell {
    override class var requiresConstraintBasedLayout: Bool { true }
    var views: [UIView] { [] }
    
    func makeConstraints() { }
    
    override func setup() {
        self.views.forEach(self.contentView.addSubview(_:))
    }
    
    override func layoutSubviews() {
        self.makeConstraints()
        super.layoutSubviews()
    }
    
    func withoutTableView() -> Self {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return self
    }
}
