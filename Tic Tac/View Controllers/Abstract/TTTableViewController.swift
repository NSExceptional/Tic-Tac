//
//  TableViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import ObjectiveC
import UIKit

enum DebounceInterval: TimeInterval, Comparable, Equatable {
    /// No delay, all events delivered
    case instant = 0
    /// Small delay which makes UI seem smoother by avoiding rapid events
    case fast = 0.05
    /// Slower than Fast, faster than ExpensiveIO
    case asyncSearch = 0.15
    /// The least frequent, at just over once per second; for I/O or other expensive operations
    case expensiveIO = 0.5
    
    static func < (lhs: DebounceInterval, rhs: DebounceInterval) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

@objc protocol SearchResultsUpdating: class {
    /// A method to handle search query update events.
    ///
    /// `searchBarDebounceInterval` is used to reduce the frequency at which this
    /// method is called. This method is also called when the search bar becomes
    /// the first responder, and when the selected search bar scope index changes.
    func updateSearchResults(_ newText: String?)
}

// MARK: - Search Bar

@objcMembers
class TTTableViewController: UITableViewController, UISearchResultsUpdating,
                             UISearchControllerDelegate, UISearchBarDelegate {
    
    /// If your subclass conforms to `SearchResultsUpdating`
    /// then this property is assigned to `self` automatically.
    ///
    /// Setting `filterDelegate` will also set this property to that object.
    weak var searchDelegate: SearchResultsUpdating? = nil
    
    /// Setting this to YES will initialize the carousel and the view.
    var showsCarousel: Bool = false {
        didSet {
            if showsCarousel {
                self.carousel = {
                    let carousel = ScopeCarousel()
                    carousel.selectedIndexChangedAction = { [weak self] idx in
                        self?.searchDelegate?.updateSearchResults(self?.searchText)
                    }

                    // UITableView won't update the header size unless you reset the header view
                    carousel.registerBlock(forDynamicTypeChanges: { [weak self] _ in
                        self?.layoutTableHeaderIfNeeded()
                    })
                    
                    self.add(carousel)
                    return carousel
                }()
            } else {
                // Carousel already shown and just set to NO, so remove it
                if let carousel = self.carousel {
                    self.remove(carousel)
                }
            }
        }
    }
    
    /// A horizontally scrolling list with functionality similar to
    /// that of a search bar's scope bar. You'd want to use this when
    /// you have potentially more than 4 scope options.
    var carousel: ScopeCarousel? = nil
    
    /// Setting this to YES will initialize searchController and the view.
    var showsSearchBar: Bool = false {
        didSet {
            if showsSearchBar {
                let results = self.searchResultsController
                let searchController = UISearchController(searchResultsController: results)
                searchController.searchBar.placeholder = "Filter"
                searchController.searchResultsUpdater = self
                searchController.delegate = self
                searchController.obscuresBackgroundDuringPresentation = false
                searchController.hidesNavigationBarDuringPresentation = false
                // Not necessary in iOS 13; remove this when iOS 13 is the minimum deployment target
                // searchController.searchBar.delegate = self

                self.automaticallyShowsSearchBarCancelButton = true
                searchController.automaticallyShowsScopeBar = false

                self.searchController = searchController
                self.addSearch(searchController)
            } else {
                // Search already shown and just set to NO, so remove it
                if let searchController = searchController {
                    removeSearch(searchController)
                }
            }
        }
    }
    
    /// Setting this to YES will make the search bar appear whenever the view appears.
    /// Otherwise, iOS will only show the search bar when you scroll up.
    var showSearchBarInitially: Bool = false
    
    /// Setting this to YES will make the search bar activate whenever the view appears.
    var activatesSearchBarAutomatically: Bool = false
    
    /// nil unless showsSearchBar is set to YES.
    ///
    /// self is used as the default search results updater and delegate.
    /// The search bar will not dim the background or hide the navigation bar by default.
    /// On iOS 11 and up, the search bar will appear in the navigation bar below the title.
    var searchController: UISearchController? = nil
    
    /// Used to initialize the search controller.
    var searchResultsController: UIViewController? = nil
    
    /// Determines how often search bar results will be "debounced."
    /// Empty query events are always sent instantly. Query events will
    /// be sent when the user has not changed the query for this interval.
    var searchBarDebounceInterval: DebounceInterval = .fast
    
    /// Whether the search bar stays at the top of the view while scrolling.
    ///
    /// Calls into self.navigationItem.hidesSearchBarWhenScrolling.
    /// Do not change self.navigationItem.hidesSearchBarWhenScrolling directly,
    /// or it will not be respsected. Use this instead.
    var pinSearchBar: Bool = false
    
    /// By default, we will show the search bar's cancel button when
    /// search becomes active and hide it when search is dismissed.
    ///
    /// Do not set the showsCancelButton property on the searchController's
    /// searchBar manually. Set this property after turning on showsSearchBar.
    ///
    /// Does nothing pre-iOS 13, safe to call on any version.
    var automaticallyShowsSearchBarCancelButton: Bool {
        get {
            return self.searchController?.automaticallyShowsCancelButton ?? false
        }
        set {
            self.searchController?.automaticallyShowsCancelButton = newValue
        }
    }
    
    /// If using the scope bar, self.searchController.searchBar.selectedScopeButtonIndex.
    /// Otherwise, this is the selected index of the carousel, or NSNotFound if using neither.
    var selectedScope: Int {
        get {
            if self.searchController?.searchBar.showsScopeBar ?? false {
                return self.searchController?.searchBar.selectedScopeButtonIndex ?? 0
            } else if self.showsCarousel {
                return self.carousel?.selectedIndex ?? 0
            } else {
                return 0
            }
        }
        set {
            if self.searchController?.searchBar.showsScopeBar ?? false {
                self.searchController?.searchBar.selectedScopeButtonIndex = selectedScope
            } else if self.showsCarousel {
                self.carousel?.selectedIndex = newValue
            }

            self.searchDelegate?.updateSearchResults(self.searchText)
        }
    }
    
    /// self.searchController.searchBar.text
    var searchText: String? {
        return searchController?.searchBar.text
    }
    
    var enableRefresh: Bool {
        get { return self.refreshControl != nil }
        set { self.refreshControl = .init(frame: .zero, primaryAction: self.refreshHandler) }
    }
    
    /// A totally optional delegate to forward search results updater calls to.
    /// If a delegate is set, updateSearchResults: is not called on this view controller.
    weak var searchResultsUpdater: SearchResultsUpdating?
    
    private var debounceTimer: Timer?
    private var didInitiallyRevealSearchBar: Bool = false
    private var style: UITableView.Style

    private lazy var tableHeaderViewContainer: UIView = {
        let container = UIView()
        self.tableView?.tableHeaderView = container
        return container
    }()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) { fatalError() }

    /// Subclasses may override to configure the controller before `viewDidLoad:`
    override init(style: UITableView.Style = .plain) {
        self.style = style
        super.init(style: style)

        // We will be our own search delegate if we implement this method
        if self.responds(to: #selector(SearchResultsUpdating.updateSearchResults(_:))) {
            self.searchDelegate = self as? SearchResultsUpdating
        }
    }

    /// Convenient for doing some async processor-intensive searching
    /// in the background before updating the UI back on the main queue.
    func onBackgroundQueue(_ bgBlock: @escaping () -> Void, thenOnMainQueue mainBlock: @escaping () -> Void) {
        DispatchQueue.global(qos: .default).async {
            bgBlock()
            DispatchQueue.main.async {
                mainBlock()
            }
        }
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.keyboardDismissMode = .onDrag
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension

        // Toolbar
        self.navigationController?.isToolbarHidden = self.toolbarItems?.isEmpty ?? true

        // On iOS 13+, the root view controller shows it's search bar no matter what.
        // Turning this off avoids some weird flash the navigation bar does when we
        // toggle navigationItem.hidesSearchBarWhenScrolling on and off. The flash
        // will still happen on subsequent view controllers, but we can at least
        // avoid it for the root view controller
        if self.navigationController?.viewControllers.first == self {
            self.showSearchBarInitially = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // When going back, make the search bar reappear instead of hiding
        if (self.pinSearchBar || self.showSearchBarInitially) && !self.didInitiallyRevealSearchBar {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }

        // Make the keyboard seem to appear faster
        if self.activatesSearchBarAutomatically {
            self.makeKeyboardAppearNow()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Allow scrolling to collapse the search bar, only if we don't want it pinned
        if #available(iOS 11.0, *) {
            if self.showSearchBarInitially && !self.pinSearchBar && !self.didInitiallyRevealSearchBar {
                // All this mumbo jumbo is necessary to work around a bug in iOS 13 up to 13.2
                // wherein quickly toggling navigationItem.hidesSearchBarWhenScrolling to make
                // the search bar appear initially results in a bugged search bar that
                // becomes transparent and floats over the screen as you scroll
                UIView.animate(withDuration: 0.2, animations: {
                    self.navigationItem.hidesSearchBarWhenScrolling = true
                    self.navigationController?.view.setNeedsLayout()
                    self.navigationController?.view.layoutIfNeeded()
                })
            }
        }

        if self.activatesSearchBarAutomatically {
            // Keyboard has appeared, now we call this as we soon present our search bar
            self.removeDummyTextField()

            // Activate the search bar
            DispatchQueue.main.async {
                // This doesn't work unless it's wrapped in this dispatch_async call
                self.searchController?.searchBar.becomeFirstResponder()
            }
        }

        // We only want to reveal the search bar when the view controller first appears.
        self.didInitiallyRevealSearchBar = true
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        // Reset this since we are re-appearing under a new
        // parent view controller and need to show it again
        self.didInitiallyRevealSearchBar = false
    }

    // MARK: - Private

    private func debounce(_ block: @escaping () -> Void) {
        self.debounceTimer?.invalidate()

        let interval = self.searchBarDebounceInterval.rawValue
        self.debounceTimer = .scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            block()
        }
    }

    private func layoutTableHeaderIfNeeded() {
        if self.showsCarousel, let carousel = self.carousel {
            carousel.frame.size.height = carousel.intrinsicContentSize.height
        }

        self.tableView?.tableHeaderView = self.tableView?.tableHeaderView
    }

    private func add(_ carousel: ScopeCarousel) {
        self.tableView?.tableHeaderView = carousel
        self.layoutTableHeaderIfNeeded()
    }

    private func remove(_ carousel: ScopeCarousel) {
        carousel.removeFromSuperview()
        self.tableView?.tableHeaderView = nil
    }

    private func addSearch(_ controller: UISearchController) {
        self.navigationItem.searchController = controller
    }

    private func removeSearch(_ controller: UISearchController) {
        self.navigationItem.searchController = nil
    }

    private static var dummyTextField = UITextField()
    
    private func makeKeyboardAppearNow() {
        Self.dummyTextField.inputAccessoryView = self.searchController?.searchBar.inputAccessoryView
        UIApplication.keyWindow.addSubview(Self.dummyTextField)
        Self.dummyTextField.becomeFirstResponder()
    }

    private func removeDummyTextField() {
        if Self.dummyTextField.superview != nil {
            Self.dummyTextField.removeFromSuperview()
        }
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        self.debounceTimer?.invalidate()
        let text = searchController.searchBar.text

        let invokeUpdater = {
            if let searchResultsUpdater = self.searchResultsUpdater {
                searchResultsUpdater.updateSearchResults(text)
            } else {
                self.searchDelegate?.updateSearchResults(text)
            }
        }

        // Only debounce if we want to, and if we have a non-empty string
        // Empty string events are sent instantly
        if let text = text, !text.isEmpty, self.searchBarDebounceInterval > .instant {
            self.debounce(invokeUpdater)
        } else {
            invokeUpdater()
        }
    }

    // MARK: Table View

    /// Not having a title in the first section looks weird with a rounded-corner table view style
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if style == .insetGrouped {
            return " "
        }

        return nil // For plain/gropued style
    }
    
    // MARK: Refresh
    
    /// Subclasses should override with refresh behavior
    func refresh(_ sender: UIRefreshControl? = nil) {
        
    }
    
    private var refreshHandler: UIAction {
        return .init { [weak self] _ in self?.refresh(self?.refreshControl) }
    }
}
