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
    
    private struct HeaderContext: YakContext {
        let origin: YakDataOrigin = .organic
    }
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    private var headerContext: HeaderContext {
        .init()
    }
    
    private lazy var header = CommentsHeaderView
        .withCommentHandler(self.addCommentPressed)
        .scrollDownButtonAction { [unowned self] in
            self.tableView.scroll(to: self.comments.count-1)
        }
    
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
        self.header.configure(with: self.yak, context: self.headerContext)
        
        // Reload data
        self.refresh()
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [CommentsDataSource(rows: $0.content)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        guard let yak = self.yak else {
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
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { [weak self] in
                    self?.refresh()
                }
            }
        }
    }
    
    override func didNearlyScrollToEnd() {
        self.addSpinnerToTableFooter()
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            self.removeSpinnerFromTableFooter()
            return self.data = .failure(.notLoggedIn)
        }
        
        guard let yak = self.yak, let lastComment = self.cursor else {
            return self.removeSpinnerFromTableFooter()
        }
        
        YYClient.current.getComments(for: yak, after: lastComment) { result in
            self.removeSpinnerFromTableFooter()
            
            if case .failure(let error) = result {
                self.errorMessage = error.localizedDescription
            }
            else {
                // Append new data
                self.data = result.map { (self.comments + $0.content, $0.cursor) }
                    .mapError { .network($0) }
            }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { [weak self] in
                    self?.didNearlyScrollToEnd()
                }
            }
        }
    }
    
    private func addCommentPressed() {
        guard let yak = self.yak else { return }
        let composer = ComposeViewController(participants: []) { text, completion in
            YYClient.current.post(comment: text, to: yak) { result in
                switch result {
                    case .success(let comment):
                        self.appendComment(comment)
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                }
            }
        }
        
        self.present(UINavigationController(rootViewController: composer), animated: true)
    }
    
    private func appendComment(_ comment: YYComment) {
        switch self.data {
            case .success(var page):
                page.content.append(comment)
                self.data = .success(page)
                self.tableView.scroll(to: page.content.count-1)
            default:
                break
        }
    }
    
    /// Dismiss the comments view controller with the given error.
    /// Used for when we couldn't load a given yak.
    private func popWithError(_ error: Error) {
        guard let nav = self.navigationController else {
            return
        }
        
        nav.popViewController(animated: true)
        nav.presentError(error, title: "Error Loading Yak")
    }
}

extension CommentsViewController {
    var comments: [YYComment] {
        switch self.data {
            case .success(let page):
                return page.content
            default:
                return []
        }
    }
    
    var cursor: String? {
        switch self.data {
            case .success(let page):
                return page.cursor
            default:
                return nil
        }
    }
}
