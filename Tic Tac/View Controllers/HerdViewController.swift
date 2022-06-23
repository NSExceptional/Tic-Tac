//
//  HerdViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit

class HerdViewController: FilteringTableViewController<YYYak> {
    enum FeedError: Error {
        case noYaks, notLoggedIn
        
        var localizedDescription: String {
            switch self {
                case .noYaks:
                    return "No Yaks"
                case .notLoggedIn:
                    return "Sign In to See Yaks"
            }
        }
    }
    
    enum FeedSort: String {
        case new, hot, top
    }
    
    private var data: DataSourceType = .failure(FeedError.noYaks) {
        didSet { self.tableView.reloadData() }
    }
    private var sort: FeedSort = .new {
        didSet { self.refresh() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
        
        let setSort: UIActionHandler = { [weak self] (_ action: UIAction) in
            self?.sort = FeedSort(rawValue: action.title.lowercased())!
        }
        
        let segmentActions: [UIAction] = [
            .init(title: "New", handler: setSort),
            .init(title: "Hot", handler: setSort),
            .init(title: "Top", handler: setSort),
        ]
        
        self.navigationItem.titleView = UISegmentedControl(frame: .zero, actions: segmentActions)
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [FeedDataSource(rows: $0)] }
    }
    
    override func refresh() {
        // Ensure logged in
        guard YYClient.shared.authToken != nil else {
            self.refreshControl?.endRefreshing()
            return self.data = .failure(FeedError.notLoggedIn)
        }
        
        YYClient.shared.getLocalYaks { result in
            self.data = result
            self.refreshControl?.endRefreshing()
        }
    }
}
