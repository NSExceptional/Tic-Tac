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
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [FeedDataSource(rows: $0.content)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        sender?.beginRefreshing()
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            sender?.endRefreshing()
            return self.data = .failure(.notLoggedIn)
        }
        
        YYClient.current.getLocalYaks { result in
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
        
        guard let lastYak = self.cursor else {
            return self.removeSpinnerFromTableFooter()
        }
        
        YYClient.current.getLocalYaks(after: lastYak) { result in
            self.removeSpinnerFromTableFooter()
            
            if case .failure(let error) = result {
                self.errorMessage = error.localizedDescription
            }
            else {
                // Append new data
                self.data = result.map { (self.posts + $0.content, $0.cursor) }
                    .mapError { .network($0) }
            }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { [weak self] in
                    self?.didNearlyScrollToEnd()
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
