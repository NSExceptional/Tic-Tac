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
    
    typealias DataProviderCallback = (Result<[T], Error>) -> Void
    typealias DataProvider = (@escaping DataProviderCallback) -> Void
    
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
    
    private var dataFetcher: DataProvider = { callback in callback(.failure(MyDataError.noData)) }
    
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
        let context = MyDataSource.Configuration(origin: .userProfile)
        return self.data.map { [MyDataSource(rows: $0, config: context)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        sender?.beginRefreshing()
        
        // Ensure logged in
        guard YYClient.current.isLoggedIn else {
            sender?.endRefreshing()
            return self.data = .failure(.notLoggedIn)
        }
        
        self.dataFetcher { result in
            self.data = result.mapError { .network($0) }
            sender?.endRefreshing()
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { [weak self] in
                    self?.refresh()
                }
            }
        }
    }
}
