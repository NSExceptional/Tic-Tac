//
//  CommentsViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit

class CommentsViewController: FilteringTableViewController<YYComment, CommentsViewController.CommentsError> {
    enum CommentsError: LocalizedError {
        case noComments, loading, notLoggedIn
        case network(Error)
        
        var errorDescription: String? {
            switch self {
                case .noComments:
                    return "No Comments"
                case .loading:
                    return "Loading…"
                case .notLoggedIn:
                    return "Sign In to See Comments"
                case .network(let error):
                    return error.localizedDescription
            }
        }
    }
    
    private var data: DataSourceType = .failure(CommentsError.loading) {
        didSet { self.reloadData() }
    }
    
    private lazy var header: CommentsHeaderView = .init(frame: UIScreen.main.bounds)
    private var yak: YYYak = .init()
    
    private var loading: Bool {
        if case .failure(let status) = self.data, case .loading = status {
            return true
        }
        
        return false
    }
    
    convenience init(for yak: YYYak) {
        self.init()
        self.yak = yak
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
        self.tableView.separatorInset = .zero
        self.tableView.delaysContentTouches = false
        self.tableView.tableHeaderView = self.header
        
        self.header.configure(with: self.yak).buttonAction {
            // TODO
        }
        
        self.refresh()
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [CommentsDataSource(rows: $0)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        guard !(self.refreshControl?.isRefreshing ?? false), let yak = self.yak else {
            return
        }
        
        sender?.beginRefreshing()
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            sender?.endRefreshing()
            return self.data = .failure(.notLoggedIn)
        }
        
        YYClient.current.getComments(for: yak) { result in
            self.data = result.mapError { .network($0) }
            sender?.endRefreshing()
        }
    }
        }
    }
}
