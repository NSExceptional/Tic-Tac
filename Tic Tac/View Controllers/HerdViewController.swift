//
//  HerdViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit

class HerdViewController: FilteringTableViewController<YYYak, HerdViewController.FeedError> {
    enum FeedError: LocalizedError {
        case noYaks, loading, notLoggedIn
        case network(Error)
        
        var errorDescription: String? {
            switch self {
                case .noYaks:
                    return "No Yaks"
                case .loading:
                    return "Loading…"
                case .notLoggedIn:
                    return "Sign In to See Yaks"
                case .network(let error):
                    return error.localizedDescription
            }
        }
    }
    
    enum FeedSort: String {
        case new, hot, top
    }
    
    private lazy var context = Context(host: self)
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    private var sort: FeedSort = .new {
        didSet { self.refresh() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
        self.emptyMessage = "No Yaks"
        self.tableView.separatorInset = .zero
        
        // Feed sort picker //
        let setSort: UIActionHandler = { [weak self] (_ action: UIAction) in
            self?.sort = FeedSort(rawValue: action.title.lowercased())!
        }
        
        let segmentActions: [UIAction] = [
            .init(title: "Hot", handler: setSort),
            .init(title: "New", handler: setSort),
            .init(title: "Top", handler: setSort),
        ]
        
        let control = UISegmentedControl(frame: .zero, actions: segmentActions)
        control.selectedSegmentIndex = 1
        self.navigationItem.titleView = control
        
        // Database subscriptions //
        
        // Update rows when user tag changes
        Container.shared.subscribe(to: UserTag.self) { event in
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .none)
        }
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [FeedDataSource(rows: $0.content, config: self.context)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
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
        
        YYClient.current.getLocalYaks { result in
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
        guard let lastYak = self.cursor else {
            return
        }
        
        @Effect var complete = false
        $complete.didSet = {
            self.loadingNextPage = !complete
            
            if !complete {
                self.addSpinnerToTableFooter()
            }
            else {
                self.removeSpinnerFromTableFooter()
            }
        }
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            defer { complete = true }
            return self.data = .failure(.notLoggedIn)
        }
        
        YYClient.current.getLocalYaks(after: lastYak) { result in
            defer { complete = true }
            
            if case .failure(let error) = result {
                self.errorMessage = error.localizedDescription
            }
            else {
                // Append new data
                self.data = result.map { (self.posts + $0.content, $0.cursor) }
                    .mapError { .network($0) }
            }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.didNearlyScrollToEnd()
                }
            }
        }
    }
}

extension HerdViewController {
    var posts: [YYYak] {
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
