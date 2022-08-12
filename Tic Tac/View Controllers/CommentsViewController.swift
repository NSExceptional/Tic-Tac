//
//  CommentsViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit
import TBAlertController

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
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    private lazy var header: CommentsHeaderView = .init(frame: UIScreen.main.bounds)
    private var yak: YYYak? {
        didSet {
            if self.isViewLoaded {
                self.yakChanged()
            }
        }
    }
    
    private var loading: Bool {
        if self.yak == nil || self.refreshingComments {
            return true
        }
        
        if case .failure(let status) = self.data, case .loading = status {
            return true
        }
        
        return false
    }
    
    private var refreshingComments: Bool = false {
        didSet {
            guard let control = self.refreshControl else { return }
            
            switch (self.refreshingComments, control.isRefreshing) {
                case (true, false):
                    control.beginRefreshing()
                case (false, true):
                    control.endRefreshing()
                case (_, _):
                    break
            }
        }
    }
    
    convenience init(for yak: YYYak) {
        self.init()
        self.yak = yak
    }
    
    convenience init(from notification: YYNotification) {
        self.init()
        
        YYClient.current.getYak(from: notification) { result in
            switch result {
                case .success(let yak):
                    // This will update the header and reload comments
                    self.yak = yak
                case .failure(let error):
                    self.data = .failure(.network(error))
                    self.popWithError(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view
        self.enableRefresh = true
        self.emptyMessage = "No Comments"
        self.tableView.separatorInset = .zero
        self.tableView.delaysContentTouches = false
        self.tableView.tableHeaderView = self.header
        
        // Call manually to load data since the initializer won't call this
        self.yakChanged()
    }
    
    /// Update header and reload comments
    private func yakChanged() {
        // Configure header with yak
        self.header.configure(with: self.yak).buttonAction {
            // TODO
        }
        
        // Reload data
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
    
    /// Dismiss the comments view controller with the given error.
    /// Used for when we couldn't load a given yak.
    private func popWithError(_ error: Error) {
        guard let nav = self.navigationController else {
            return
        }
        
        nav.popViewController(animated: true)
        
        TBAlert.make({ make in
            make.title("Error Loading Yak")
            make.message(error.localizedDescription)
            make.button("Dismiss")
        }, showFrom: nav)
    }
}
