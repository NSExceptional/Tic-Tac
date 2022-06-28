//
//  VotableDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit

class VotableDataSource<T: YYVotable, C: YakCell>: DataSource {
    typealias Model = T
    typealias Cell = C
    
    let rows: [Model]

    var title: String? { nil }
    var numberOfRows: Int { self.rows.count }
    var reusableCellRegistry: [UITableViewCell.Type] { [C.self] }
    
    var sectionIndex: Int = 0
    var filterText: String? = nil
    
    init(rows: [Model] = []) {
        self.rows = rows
    }
    
    func cell(_ table: UITableView, for ip: IndexPath) -> UITableViewCell {
        return Cell.dequeue(table, ip).configure(with: self.rows[ip.row])
    }
    
    func canSelectRow(_ row: Int) -> Bool {
        return false
    }
    
    func viewControllerToPush(for row: Int) -> UIViewController? {
        return nil
    }
}
