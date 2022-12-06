//
//  FilteringTableViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

// MARK: - TableViewFiltering

protocol TableViewFiltering: SearchResultsUpdating {
    /// A string to display in leiu of table content. Only used when there are no sections or no error.
    var emptyMessage: String? { get set }
    /// An array of visible, "filtered" sections. For example,
    /// if you have 3 sections in `allSections` and the user searches
    /// for something that matches rows in only one section, then
    /// this property would only contain that on matching section.
    var sections: [TableViewSection] { get set }
    /// An array of all possible sections. Empty sections are to be removed
    /// and the resulting array stored in the `section` property. Setting
    /// this property should immediately set `sections` to `nonemptySections` 
    ///
    /// Do not manually initialize this property, it will be
    /// initialized for you using the result of `makeSections`.
    var allSections: [TableViewSection] { get set }
    /// This computed property should filter `allSections` for assignment to `sections`
    var nonemptySections: [TableViewSection] { get }
    /// This should be able to re-initialize `allSections`
    func makeSections() -> Result<[TableViewSection], Error>
}

// MARK: - FilteringTableViewController

/// A table view which implements `UITableView*` methods using arrays of
/// `TableViewSection` objects provied by a special delegate.
///
/// Automatically populates `tableView.backgroundView` with a label displaying
/// a message in the form of an error, or the content of `emptyMessage`.
@objcMembers
class FilteringTableViewController<T, E: Error>: TTTableViewController, TableViewFiltering {
    typealias DataSourceType = Result<Page<T>, E>
    
    // TODO: create a new table view controller with domain specific stuff in it
    var onNavigationPop = { }
    
    /// Stores the current search query.
    var filterText: String? = nil
    
    /// This property is set to `self` by default at the end of `loadView`.
    ///
    /// This property is used to power almost all of the table view's data source
    /// and delegate methods automatically, including row and section filtering
    /// when the user searches, 3D Touch context menus, row selection, etc.
    ///
    /// Setting this property will also set `searchDelegate` to that object.
    weak var filterDelegate: TableViewFiltering? = nil {
        didSet {
            // Case: view not yet loaded, no delegate yet; do nothing.
            // When the view loads, this will be called again.
            guard let delegate = self.filterDelegate else {
                return
            }
            
            switch delegate.makeSections() {
                case .success(let sections):
                    self.errorMessage = nil
                    delegate.allSections = sections
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    delegate.allSections = []
            }

            if self.isViewLoaded {
                self.registerCellsForReuse()
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /// If enabled, all filtering will be done by calling
    /// `onBackgroundQueue:thenOnMainQueue:` with the UI updated on the main queue.
    var filterInBackground: Bool = false
    
    // MARK: TableViewFiltering

    var sections: [TableViewSection] = [] {
        didSet {
            // Allow sections to reload a portion of the table view at will
            for (idx, section) in self.sections.enumerated() {
                section.sectionIndex = idx
            }
            
            // Update and unhide the background label
            self.tableView.backgroundView?.isHidden = !sections.isEmpty
            if self.sections.isEmpty {
                self.backgroundLabel.text = self.errorMessage ?? self.emptyMessage
            }
        }
    }
    
    var errorMessage: String? = nil
    var emptyMessage: String? = nil
    lazy var backgroundLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .preferredFont(forTextStyle: .headline)
        l.font = l.font.withSize(24)
        return l
    }()

    var allSections: [TableViewSection] = [] {
        didSet {
            // Only display nonempty sections
            self.sections = self.nonemptySections
        }
    }
    
    /// Subclasses can override to hide specific sections under certain conditions
    /// if using `self` as the `filterDelegate,` as is the default.
    ///
    /// For example, the object explorer hides the description section when searching.
    var nonemptySections: [TableViewSection] {
        return self.filterDelegate?.allSections.filter { $0.numberOfRows > 0 } ?? []
    }

    // MARK: - View controller lifecycle

    override func loadView() {
        super.loadView()
        
        self.tableView.backgroundView = self.backgroundLabel
        self.tableView.tableFooterView = SpinnerFooterView(frame: .square(80))

        if self.filterDelegate == nil {
            // This will trigger the initial call to reloadData once the view loads
            self.filterDelegate = self
        } else {
            self.registerCellsForReuse()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.navigationController == nil {
            self.onNavigationPop()
            // This is necessary to break any retain cycles in the closure
            self.onNavigationPop = { }
        }
    }

    private func registerCellsForReuse() {
        self.filterDelegate?.allSections.forEach { section in
            self.tableView?.registerCells(section.reusableCellRegistry)
        }
    }
    
    func reloadData() {
        // Force reload all data by re-setting the delegate
        let delegate = self.filterDelegate
        self.filterDelegate = delegate
    }

    /// Recalculates the non-empty sections and reloads the table view.
    ///
    /// Subclasses may override to perform additional reloading logic,
    /// such as calling `-reloadSections` if needed. Be sure to call
    /// `super` after any logic that would affect the appearance of 
    /// the table view, since the table view is reloaded last.
    ///
    /// Called at the end of this class's implementation of `updateSearchResults:`
    func reloadNonemptySections() {
        self.reloadData(self.nonemptySections)
    }

    func reloadData(_ nonemptySections: [TableViewSection]) {
        // Recalculate displayed sections
        self.filterDelegate?.sections = nonemptySections

        // Refresh table view
        if self.isViewLoaded {
            self.tableView?.reloadData()
        }
    }

    /// Invoke this method to call `-reloadData` on each section
    /// in `self.filterDelegate.allSections`.
    func reloadSections() {
        self.filterDelegate?.allSections.forEach { $0.reloadData() }
    }

    // MARK: - Search

    @objc func updateSearchResults(_ newText: String?) {
        let filter = {
            self.filterText = newText

            // Sections will adjust data based on this property
            self.filterDelegate?.allSections.forEach { section in
                section.filterText = newText
            }
        }

        if self.filterInBackground {
            onBackgroundQueue(filter) { // Then on main...
                if self.searchText == newText {
                    self.reloadData()
                }
            }
        } else {
            filter()
            self.reloadData()
        }
    }

    /// If using `self` as the `filterDelegate,` as is the default,
    /// subclasses should override to provide the sections for the table view.
    func makeSections() -> Result<[TableViewSection], Error> {
        return .success([])
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterDelegate?.sections.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterDelegate?.sections[section].numberOfRows ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.filterDelegate?.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let reuse = self.filterDelegate?.sections[indexPath.section].reuseIdentifier(for: indexPath.row)
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuse ?? "", for: indexPath)
        let cell = self.filterDelegate!.sections[indexPath.section].cell(tableView, for: indexPath)
        cell.layoutIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.filterDelegate?.sections[indexPath.section].canSelectRow(indexPath.row) ?? false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.filterDelegate?.sections[indexPath.section]

        let action = section?.didSelectRowAction(indexPath.row)
        let details = section?.viewControllerToPush(for: indexPath.row)

        if let action = action {
            action(self)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let details = details {
            self.navigationController?.pushViewController(details, animated: true)
        } else {
            NSException.raise(
                name: NSExceptionName.internalInconsistencyException,
                message: "Row is selectable but has no action or view controller"
            )
        }
    }

    override func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        let section = self.filterDelegate?.sections[indexPath.section]
        let title = section?.menuTitle(for: indexPath.row) ?? ""
        let menuItems = section?.menuItems(for: indexPath.row, sender: self) ?? []

        if !menuItems.isEmpty {
            return .init(identifier: nil, previewProvider: nil) { suggestedActions in
                return UIMenu(title: title, children: menuItems)
            }
        }

        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let section = self.filterDelegate?.sections[indexPath.section] else { return nil }
        return UISwipeActionsConfiguration(actions: section.leadingSwipeActions(for: indexPath.row))
    }
    
    override func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let section = self.filterDelegate?.sections[indexPath.section] else { return nil }
        return UISwipeActionsConfiguration(actions: section.trailingSwipeActions(for: indexPath.row))
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = self.sections[indexPath.section].numberOfRows
        let isLast = indexPath.row == numberOfRows - 1
        
        // Trigger didNearlyScrollToEnd() when we reach the last 4 rows
        if indexPath.row == numberOfRows - 5 || numberOfRows < 5 && isLast {
            if !self.loadingNextPage {
                self.didNearlyScrollToEnd()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isAtBottom && !self.loadingNextPage {
            self.didNearlyScrollToEnd()
        }
    }
    
    // MARK: Pagination
    
    private var spinnerFooter: SpinnerFooterView {
        return self.tableView.tableFooterView as! SpinnerFooterView
    }
    
    /// Subclasses should override
    var loadingNextPage: Bool = false
    
    func addSpinnerToTableFooter() {
        self.spinnerFooter.start()
    }
    
    func removeSpinnerFromTableFooter() {
        self.spinnerFooter.stop()
    }
    
    /// Subclases should override with pagination logic.
    ///
    /// - warning: There is a potential for this method to be called more than once
    /// in rapid succession. It is unlikely, but possible. Paginators should implement
    /// barriers to prevent fetching the same page more than once.
    func didNearlyScrollToEnd() {
        
    }
}
