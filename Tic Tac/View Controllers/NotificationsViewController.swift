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
        
        self.title = "Notifications"
        self.enableRefresh = true
        self.emptyMessage = "No Notifications"
        self.tableView.separatorInset = .zero
        
        // Button to mark all notifications read
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear Unread",
            image: UIImage(systemName: "bell.badge.fill"),
            primaryAction: .init { _ in
                self.refreshControl?.revealAndBeginRefreshing()
                self.title = "Clearning Unread Notifications…"
                
                YYClient.current.clearUnreadNotifications { error in
                    if let error = error {
                        self.presentError(error, title: "Error Clearing Unread Notifications")
                        self.refreshControl?.endRefreshing()
                        self.title = "Notifications"
                    }
                    else {
                        self.refresh(self.refreshControl)
                    }
                }
            }
        )
        
        // Database subscriptions //
        
        // Update rows when user tag changes
        Container.shared.subscribe(to: YYStoredPost.self) { event in
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .none)
        }
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
            return self.data = .failure(.notLoggedIn)
        }
        
        self.title = "Loading…"
        
        // let cursor: String? = "MjAyMi0wNS0yNCAxOTowNzo0OS40MTA3NzgrMDA6MDA="
        let cursor: String? = nil
        YYClient.current.getNotifications(after: cursor) { result in
            self.data = result.mapError { .network($0) }
            sender?.endRefreshing()
            
            if result.failed {
                self.title = "Reauthenticating…"
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.refresh()
                }
            }
            else {
                self.title = "Notifications"
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
                LoginController(host: self, client: .current).requireLogin(reset: true) { host in
                    host.didNearlyScrollToEnd()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        // Mark row read
        self.notifications[indexPath.row].read = true
        tableView.reloadRows(at: [indexPath], with: .none)
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
