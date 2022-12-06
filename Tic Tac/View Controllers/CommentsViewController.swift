//
//  CommentsViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit
import TBAlertController

private typealias CommentsViewControllerDataSourceType = CommentsViewController.DataSourceType

private extension CommentsViewControllerDataSourceType {
    var loading: Bool {
        if let error = self.error, case .loading = error {
            return true
        }
        
        return false
    }
}

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
    
    private lazy var context = Context(host: self)
    private lazy var headerContext = Context(host: self, loading: self.loadingYak)
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    private lazy var header = CommentsHeaderView
        .withCommentHandler { [unowned self] in self.addCommentPressed() }
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
        return self.loadingYak || self.loadingNextPage
    }
    
    private var loadingYak: Bool {
        return self.yak == nil && self.data.loading
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
                    
                    // Cache the yak for notification descriptions
                    Container.shared.ensureUserExists(yak.authorIdentifier, latestEmoji: yak.emoji)
                    try! Container.shared.insertIfNotExists(YYStoredPost(from: yak))
                    
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
        
        
        // Database subscriptions //
        
        // Update rows when user tag changes
        let subscription = Container.shared.subscribe(to: UserTag.self) { event in
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .fade)
        }

        // Remove database subscriber when we're removed from the navigation stack
        self.onNavigationPop = {
            Container.shared.unsubscribe(subscription, from: UserTag.self)
        }
        
        // TODO: there is a retain cycle here somewhere, and it's NOT CommentsHeaderView or the subscriptions above
    }
    
    /// Update header and reload comments
    private func yakChanged() {
        // Configure header with yak
        self.header.configure(with: self.yak, context: self.headerContext)
        
        // Reload data
        self.refresh()
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [CommentsDataSource(rows: $0.content, config: self.context)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        guard let yak = self.yak else {
            return
        }
        
        @Effect var complete = false
        $complete.didSet = {
            self.loadingNextPage = !complete
            
            if !complete {
                sender?.beginRefreshing()
            }
            else {
                sender?.endRefreshing()
            }
        }
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            defer { complete = true }
            return self.data = .failure(.notLoggedIn)
        }
        
        YYClient.current.getComments(for: yak) { result in
            defer { complete = true }
            self.data = result.mapError { .network($0) }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.refresh()
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
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.didNearlyScrollToEnd()
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
