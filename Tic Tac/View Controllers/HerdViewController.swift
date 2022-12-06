//
//  HerdViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit

class HerdViewController: FilteringTableViewController<YYYak, HerdViewController.FeedError> {
    typealias FeedSort = YYClient.Feed.Sort
    
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
    
    // MARK: Properties
    
    private lazy var context = Context(host: self)
    
    private var data: DataSourceType = .failure(.loading) {
        didSet { self.reloadData() }
    }
    
    private var locationSetters: [UIAction] {
        LocationManager.favorites.map { [unowned self] location in
            location.action { _ in
                LocationManager.locationType = .override(location)
                
                self.title = location.name
                self.reloadBarItems(refresh: true)
            }
        }
    }
    
    private lazy var sortSetters: [UIAction] = FeedSort.all.map { [unowned self] sort in
        sort.action { _ in self.sort = sort }
    }
    private var sort: FeedSort = .new {
        didSet {
            self.reloadBarItems(refresh: true)
        }
    }
    
    /// Different icon depending on sort type
    private var sortBarItem: UIBarButtonItem {
        UIBarButtonItem(
            title: "Sort",
            image: .symbol(self.sort.symbol),
            menu: .init(children: self.sortSetters)
        )
    }
    
    /// This is either the "user location" symbol or a map pin
    private var locationBarItem: UIBarButtonItem {
        UIBarButtonItem(
            title: "Location",
            image: .symbol(LocationManager.locationType == .current ? "location.fill" : "mappin.and.ellipse"),
            menu: .init(children: self.locationSetters)
        )
    }
    
    /// Called initially in `viewDidLoad()`
    private func reloadBarItems(refresh: Bool) {
        // Update sort item to change icon
        self.navigationItem.leftBarButtonItems = [self.sortBarItem, self.locationBarItem]
        
        if YYClient.current.isLoggedIn {
            self.showRefreshControlAndRefresh()
        }
    }
    
    // MARK: Overrides
    
    override var loadingNextPage: Bool {
        get { return self.dataIsLoading || super.loadingNextPage }
        set { super.loadingNextPage = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = UserDefaultsStore.standard.selectedLocation ?? "Nearby"
        
        self.enableRefresh = true
        self.emptyMessage = "No Yaks"
        self.tableView.separatorInset = .zero
        
        // Compose button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Compose",
            image: UIImage(systemName: "square.and.pencil"),
            primaryAction: .init { _ in self.composeYak() }
        )
        
        self.reloadBarItems(refresh: false)
        
        // Database subscriptions //
        
        // Update rows when user tag changes
        let subscription = Container.shared.subscribe(to: UserTag.self) { event in
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .fade)
        }
        
        // Remove database subscriber when we're removed from the navigation stack
        self.onNavigationPop = {
            Container.shared.unsubscribe(subscription, from: UserTag.self)
        }
        
        // Location subscriptions //
        LocationManager.observeFavorites { _ in
            self.reloadBarItems(refresh: false)
        }
        LocationManager.observeLocation { (_, name) in
            self.title = name ?? "Nearby"
            self.reloadBarItems(refresh: false)
        }
    }
    
    override func makeSections() -> Result<[TableViewSection], Error> {
        return self.data.map { [FeedDataSource(rows: $0.content, config: self.context)] }
            .mapError { $0 as Error }
    }
    
    override func refresh(_ sender: UIRefreshControl? = nil) {
        // Single switch to toggle loading and refreshing
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
        guard YYClient.current.isLoggedIn else {
            defer { complete = true }
            return self.data = .failure(.notLoggedIn)
        }
        
        YYClient.current.getLocalYaks(sort: self.sort) { result in
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
        
        YYClient.current.getLocalYaks(after: lastYak, sort: self.sort) { result in
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

// MARK: Composition
extension HerdViewController {
    func composeYak() {
        let composer = ComposeViewController { text, completion in
            YYClient.current.post(yak: text) { result in
                switch result {
                    case .success(let yak):
                        self.prependYak(yak)
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                }
            }
        }
        
        self.present(UINavigationController(rootViewController: composer), animated: true)
    }
    
    private func prependYak(_ yak: YYYak) {
        switch self.data {
            case .success(var page):
                page.content.insert(yak, at: 0)
                self.data = .success(page)
                // self.tableView.scroll(to: 0)
            default:
                break
        }
    }
}

// MARK: Sorting
extension HerdViewController.FeedSort {
    var symbol: String {
        switch self {
            case .new: return "sparkles"
            case .hot: return "flame"
            case .top: return "crown.fill"
        }
    }
    
    func action(withHandler action: @escaping UIActionHandler) -> UIAction {
        let image = UIImage(systemName: self.symbol)
        return .init(title: self.rawValue.capitalized, image: image, handler: action)
    }
}

// MARK: Location choosing
extension SavedLocation {
    func action(withHandler action: @escaping UIActionHandler) -> UIAction {
        return .init(title: self.name, handler: action)
    }
}

// MARK: Convenience Accessors
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
    
    /// Whether self.data == .failure(.loading)
    var dataIsLoading: Bool {
        switch self.data {
            case .failure(let error):
                switch error {
                    case .loading:
                        return true
                    default:
                        return false
                }
            default:
                return false
        }
    }
}
