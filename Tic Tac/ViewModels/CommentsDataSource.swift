//
//  CommentsDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import UIKit
import YakKit

class CommentsDataSource: DataSource {
    typealias Model = YYComment
    
    let rows: [Model]

    var title: String? { nil }
    var numberOfRows: Int { self.rows.count }
    
    var sectionIndex: Int = 0
    var filterText: String? = nil
    
    init(rows: [Model] = []) {
        self.rows = rows
    }
    
    func configureCell(_ cell: UITableViewCell, for row: Int) {
        
    }
    
    func canSelectRow(_ row: Int) -> Bool {
        return false
    }
}
