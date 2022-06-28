//
//  BaseCell.swift
//  Receiptie
//
//  Created by Tanner Bennett on 4/18/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import UIKit
import SnapKit
import YakKit

class BaseCell: UITableViewCell, CellBuilder {
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    class var preferredStyle: CellStyle { .default }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: type(of: self).preferredStyle, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    func setup() {
        
    }
}

protocol CellBuilder: UITableViewCell { }

extension CellBuilder {
    static func dequeue(_ tableView: UITableView, _ indexPath: IndexPath) -> Self {
        return tableView.dequeueCell(for: indexPath)
    }
}
