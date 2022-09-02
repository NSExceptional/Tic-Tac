//
//  VotableDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import YakKit

class ModelDataSource<T: YYThing, C: ConfigurableCell>: DataSource {
    typealias Model = T
    typealias Cell = C
    
    let rows: [Model]
    let configuration: YakContext

    var title: String? { nil }
    var numberOfRows: Int { self.rows.count }
    var reusableCellRegistry: [UITableViewCell.Type] { [C.self] }
    
    var sectionIndex: Int = 0
    var filterText: String? = nil
    
    required init(rows: [Model], config: YakContext) {
        self.configuration = config
        self.rows = rows
    }
    
    func cell(_ table: UITableView, for ip: IndexPath) -> UITableViewCell {
        let data = self.rows[ip.row] as! Cell.Model
        return Cell.dequeue(table, ip).configure(with: data, context: self.configuration)
    }
    
    func canSelectRow(_ row: Int) -> Bool {
        return false
    }
    
    func viewControllerToPush(for row: Int) -> UIViewController? {
        return nil
    }
    
    func leadingSwipeActions(for row: Int) -> [UIContextualAction] {
        return []
    }
    
    func trailingSwipeActions(for row: Int) -> [UIContextualAction] {
        return []
    }
}

fileprivate extension YYVoteStatus {
    static let upvoteIcon = UIImage(systemName: "arrow.up")!
    static let downvoteIcon = UIImage(systemName: "arrow.down")!
    static let clearIcon = UIImage(systemName: "xmark")!
}

class VotableDataSource<V: YYVotable, C: YakCell>: ModelDataSource<V, C> {
    
    override func cell(_ table: UITableView, for ip: IndexPath) -> UITableViewCell {
        return Cell.dequeue(table, ip).configure(with: self.rows[ip.row], context: self.configuration)
    }
    
    private func swipeColor(for status: YYVoteStatus) -> UIColor {
        switch status {
            case .upvoted:
                return .systemOrange
            case .downvoted:
                return .systemIndigo
            default:
                return .secondarySystemBackground
        }
    }
    
    private func swipeImage(for status: YYVoteStatus) -> UIImage {
        switch status {
            case .upvoted:
                return YYVoteStatus.upvoteIcon
            case .downvoted:
                return YYVoteStatus.downvoteIcon
            default:
                return YYVoteStatus.clearIcon
        }
    }
    
    private func swipeActions(for row: Int, side: YYVoteStatus) -> [UIContextualAction] {
        let votable = self.rows[row]
        let newStatus: YYVoteStatus = votable.voteStatus == side ? .none : side
        
        return [
            UIContextualAction { action, button, callback in
                guard let cell = button.superview?.superview?.subviews[1] as? VotableDataSource.Cell else {
                    return callback(false)
                }
                
                callback(true)
                cell.adjustVote(on: votable, newStatus, callback: { _ in })
            }
            .color(self.swipeColor(for: newStatus))
            .image(self.swipeImage(for: newStatus))
        ]
    }
    
    override func leadingSwipeActions(for row: Int) -> [UIContextualAction] {
        return self.swipeActions(for: row, side: .downvoted)
    }
    
    override func trailingSwipeActions(for row: Int) -> [UIContextualAction] {
        return self.swipeActions(for: row, side: .upvoted)
    }
}
