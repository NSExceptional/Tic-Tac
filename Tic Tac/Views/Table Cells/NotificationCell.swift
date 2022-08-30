//
//  NotificationCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import YakKit

class NotificationCell: AutoLayoutCell, ConfigurableCell {
    typealias Model = YYNotification
    
    override class var preferredStyle: CellStyle {
        .subtitle
    }
    
    private let header = UILabel(textStyle: .headline)
    private let subheader = UILabel(textStyle: .body).multiline()
    private let footer = UILabel(font: .monospace(.footnote)).color(.secondaryLabel)
    
    private lazy var stack = UIStackView(arrangedSubviews: [header, subheader, footer])
        .alignment(.leading).axis(.vertical).distribution(.fill).spacing(5)
    
    override var views: [UIView] { [stack] }
    
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
    }
    
    override func makeConstraints() {
        let edges = UIEdgeInsets(vertical: 8, horizontal: 16)

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edges)
        }
    }
    
    func configure(with notif: YYNotification, context: CellContext, client: YYClient) -> Self {
        self.header.text = notif.subject
        self.subheader.text = notif.content
        self.footer.text = notif.thingIdentifier?[6...]
        
        self.subheader.isHidden = notif.content == nil
        
        self.header.textColor = notif.unread ? self.tintColor : .label
        return self
    }
}
