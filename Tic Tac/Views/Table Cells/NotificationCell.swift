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
    
//    override var views: [UIView] { [textLabel!, detailTextLabel!] }
    
    override func setup() {
        super.setup()
        self.accessoryType = .disclosureIndicator
        
        self.textLabel?.font = .preferredFont(forTextStyle: .headline)
        self.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
    }
    
//    override func makeConstraints() {
//        let edges = UIEdgeInsets(vertical: 8, horizontal: 15)
//
//        title.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(edges)
//        }
//    }
    
    func configure(with notif: YYNotification, client: YYClient) -> Self {
        self.textLabel?.text = notif.subject
        self.detailTextLabel?.text = notif.content
        
        self.textLabel?.textColor = notif.unread ? self.tintColor : .label
        return self
    }
}
