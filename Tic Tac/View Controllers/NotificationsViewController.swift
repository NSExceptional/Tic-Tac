//
//  NotificationsViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/10/22.
//

import UIKit
import YakKit

class NotificationsViewController: FilteringTableViewController<YYNotification, NotificationsViewController.NotifsError> {
    enum NotifsError: LocalizedError {
        case noNotifications, loading, notLoggedIn
        case network(Error)
        
        var errorDescription: String? {
            switch self {
                case .noNotifications:
                    return "No Notifications"
                case .loading:
                    return "Loading…"
                case .notLoggedIn:
                    return "Sign In to See Yaks"
                case .network(let error):
                    return error.localizedDescription
            }
        }
    }
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
        self.emptyMessage = "No Notifications"
        self.tableView.separatorInset = .zero
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [NotifDataSource(rows: $0)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        sender?.beginRefreshing()
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            sender?.endRefreshing()
            return self.data = .failure(NotifsError.notLoggedIn)
        }
        
        YYClient.current.getNotifications { result in
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
