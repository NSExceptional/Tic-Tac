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
    
    private var consolidateItems = true {
        didSet {
            guard self.data.succeeded else { return }
            
            // Case: filter existing notifications without refreshing
            if consolidateItems {
                self.data = self.consolidate(data: self.data)
            }
            // Case: reload all notifications to get un-consolidated list
            else {
                self.showRefreshControlAndRefresh()
            }
        }
    }
    
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
                // TODO: this should have some logic to guard against refreshing 4+ pages of notifs
                self.refreshControl?.revealAndBeginRefreshing()
                self.title = "Clearing Unreads…"
                
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
        
        // Button to disable notification de-duping
        func updateConsolidateButton() {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Toggle Duplicates",
                image: UIImage(systemName: self.consolidateItems ? "arrow.triangle.pull" : "arrow.triangle.branch"),
                primaryAction: .init { _ in
                    // TODO: this should have some logic to guard against refreshing 4+ pages of notifs
                    updateConsolidateButton()
                    self.consolidateItems = !self.consolidateItems
                }
            )
        }
        
        updateConsolidateButton()
        
        // Database subscriptions //
        
        // Update rows when user tag changes
        let subscription = Container.shared.subscribe(to: YYStoredPost.self) { event in
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .none)
        }
        
        // Remove database subscriber when we're removed from the navigation stack
        self.onNavigationPop = {
            Container.shared.unsubscribe(subscription, from: YYStoredPost.self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.navigationController == nil {
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
            self.data = self.consolidateIfWanted(data: result.mapError { .network($0) })
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
            let allPosts = self.data + result.mapError { .network($0) }
            self.data = self.consolidateIfWanted(data: allPosts)
            
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

extension NotificationsViewController.DataSourceType {
    static func +(ls: Self, rs: Self) -> Self {
        return rs.map { newPage in
            let existingPosts = ls.value?.content ?? []
            let newPosts = newPage.content
            return (existingPosts + newPosts, newPage.cursor)
        }
    }
}
extension NotificationsViewController {
    
    /// Used to unique a list of YYNotifications without altering existing conformances
    struct NotifGroup: Hashable, Equatable {
        let notification: YYNotification
        let hash: Int
        
        init(notif: YYNotification) {
            self.notification = notif
            self.hash = notif.thingIdentifier?.hash ?? notif.identifier.hash
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.hash)
        }
        
        static func == (lhs: NotifGroup, rhs: NotifGroup) -> Bool {
            return lhs.hash == rhs.hash
        }
    }
    
    func consolidateIfWanted(data: DataSourceType) -> DataSourceType {
        if self.consolidateItems {
            return self.consolidate(data: data)
        }
        
        return data
    }
    
    func consolidate(data: DataSourceType) -> DataSourceType {
        return data.map {
            let flattened = $0.content
                .map { NotifGroup(notif: $0) }
                .uniqued()
                .map(\.notification)
            
            return (flattened, $0.cursor)
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
