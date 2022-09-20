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
    
    static let footerIDTAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.monospace(.footnote)
    ]
    
    private let header = UILabel(textStyle: .headline)
    private let subheader = UILabel(font: .italic(.body)).multiline()
    private let footer = UILabel(textStyle: .footnote).color(.secondaryLabel).multiline()
    
    private lazy var stack = UIStackView(arrangedSubviews: [header, subheader, footer])
        .alignment(.leading).axis(.vertical).distribution(.fill).spacing(5)
    
    override var views: [UIView] { [stack] }
    
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
        self.stack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func makeConstraints() {
        let edges = UIEdgeInsets(vertical: 8, horizontal: 16)

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edges)
        }
    }
    
    func configure(with notif: YYNotification, context: YakContext) -> Self {
        let yakTitle = Container.shared.titleForYak(with: notif.thingIdentifier)
        self.header.text = notif.subject
        self.subheader.text = notif.content
        
        let footerText: StringBuilder.Component = yakTitle != nil ? .text(yakTitle) :
            .attrText(notif.unencodedThingIdentifier, Self.footerIDTAttributes)
                          
        self.footer.attributedText = StringBuilder(
            components: [
                .symbol("clock"), .leadingSpace(.text(notif.age)),
                .symbol("tag"), .leadingSpace(footerText),
            ]
        ).attributedString
        
        self.subheader.isHidden = notif.content == nil
        
        self.header.textColor = notif.unread ? self.tintColor : .label
        return self
    }
}
