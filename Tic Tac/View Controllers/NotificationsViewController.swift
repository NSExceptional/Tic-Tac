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
    
    private lazy var context = Context(host: self)
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
        self.emptyMessage = "No Notifications"
        self.tableView.separatorInset = .zero
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear Unread",
            image: UIImage(systemName: "bell.badge.fill"),
            primaryAction: .init { _ in
                self.refreshControl?.beginRefreshing()
                YYClient.current.clearUnreadNotifications { error in
                    if let error = error {
                        self.presentError(error, title: "Error Clearing Unread Notifications")
                        self.refreshControl?.endRefreshing()
                    }
                    else {
                        self.refresh(self.refreshControl)
                    }
                }
            }
        )
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [NotifDataSource(rows: $0.content, config: self.context)] }
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
    
    
    override func didNearlyScrollToEnd() {
        self.addSpinnerToTableFooter()
        
        // Ensure logged in
        guard YYClient.current.authToken != nil else {
            self.removeSpinnerFromTableFooter()
            return self.data = .failure(.notLoggedIn)
        }
        
        guard let lastNotif = self.cursor else {
            return self.removeSpinnerFromTableFooter()
        }
        
        YYClient.current.getNotifications(after: lastNotif) { result in
            self.removeSpinnerFromTableFooter()
            
            // Append new posts
            self.data = result.map { (self.notifications + $0.content, $0.cursor) }
                .mapError { .network($0) }
            
            if result.failed {
                LoginController(host: self, client: .current).requireLogin(reset: true) { [weak self] in
                    self?.didNearlyScrollToEnd()
                }
            }
        }
    }
}

extension NotificationsViewController {
    var notifications: [YYNotification] {
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
