//
//  MyDataViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/18/22.
//

import UIKit
import YakKit

class MyCommentsViewController: MyDataViewController<YYComment, CommentsDataSource, CommentCell> { }
class MyPostsViewController: MyDataViewController<YYYak, FeedDataSource, YakCell> { }

class MyDataViewController<T: YYVotable, MyDataSource: VotableDataSource<T, Cell>, Cell: YakCell>:
        FilteringTableViewController<T, MyDataViewController.MyDataError> {
    
    typealias DataProviderCallback = (Result<Page<T>, Error>) -> Void
    typealias DataProvider = (_ after: String?, @escaping DataProviderCallback) -> Void
    
    enum MyDataError: LocalizedError {
        case noData, loading, notLoggedIn
        case network(Error)
        
        var errorDescription: String? {
            switch self {
                case .noData:
                    return "No Data"
                case .loading:
                    return "Loading…"
                case .notLoggedIn:
                    return "Sign In to See Data"
                case .network(let error):
                    return error.localizedDescription
            }
        }
    }
    
    private lazy var context = Context(host: self, origin: .userProfile)
    
    private var dataFetcher: DataProvider = { _, callback in callback(.failure(MyDataError.noData)) }
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    convenience init(title: String, dataFetcher: @escaping DataProvider) {
        self.init()
        self.title = title
        self.dataFetcher = dataFetcher
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view
        self.enableRefresh = true
        self.emptyMessage = "No Data"
        self.tableView.separatorInset = .zero
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [MyDataSource(rows: $0.content, config: self.context)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        sender?.beginRefreshing()
        
        // Ensure logged in
        guard YYClient.current.isLoggedIn else {
            sender?.endRefreshing()
            return self.data = .failure(.notLoggedIn)
        }
        
        self.dataFetcher(nil) { result in
            self.data = result.mapError { .network($0) }
            sender?.endRefreshing()
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.refresh()
                }
            }
        }
    }
    
    override func didNearlyScrollToEnd() {
        guard let nextPage = self.cursor else {
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
        
        self.dataFetcher(nextPage) { result in
            defer { complete = true }
            
            if case .failure(let error) = result {
                self.errorMessage = error.localizedDescription
            }
            else {
                // Append new data
                self.data = result.map { (self.dataItems + $0.content, $0.cursor) }
                    .mapError { .network($0) }
            }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.refresh()
                }
            }
        }
    }
}

extension MyDataViewController {
    var dataItems: [T] {
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
