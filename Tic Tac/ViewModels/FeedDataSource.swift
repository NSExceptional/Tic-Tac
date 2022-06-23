//
//  FeedDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/22/22.
//

import UIKit

class FeedDataSource: TableViewSection {
    typealias Model = Any
    
    let rows: [Model]

    var title: String? { nil }
    var numberOfRows: Int { self.rows.count }
    
    var sectionIndex: Int = 0
    var filterText: String? = nil
    
    internal init(rows: [Model]) {
        self.rows = rows
    }
    
    func configureCell(_ cell: UITableViewCell, for row: Int) {
        
    }
    
    func canSelectRow(_ row: Int) -> Bool {
        return true
    }
}