//
//  SingleRowSection.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

/// A section providing a specific single row.
///
/// You may optionally provide a view controller to push when the row
/// is selected, or an action to perform when it is selected.
/// Which one is used first is up to the table view data source.
@objcMembers
class SingleRowSection: TableViewSection {
    
    var pushOnSelection: UIViewController?
    var selectionAction: ActionHandler?
    /// Called to determine whether the single row should display itself or not.
    var filterMatcher: ((_ filterText: String) -> Bool)?
    private var reuseIdentifier: String
    private var cellConfiguration: ((UITableViewCell) -> Void)
    private var lastTitle: String?
    private var lastSubitle: String?

    /// @param reuseIdentifier if nil, kDefaultCell is used.

    // MARK: - Public

    init(sectionTitle: String?, reuseIdentifier: String?, cellConfiguration: @escaping (UITableViewCell) -> Void) {
        self.reuseIdentifier = reuseIdentifier ?? Self.defaultReuseID
        self.cellConfiguration = cellConfiguration
        super.init()
        self.title = sectionTitle
    }

    // MARK: - Overrides

    override var numberOfRows: Int {
        if let filter = self.filterMatcher, let text = filterText, !text.isEmpty {
            return filter(text) ? 1 : 0
        }

        return 1
    }

    override func canSelectRow(_ row: Int) -> Bool {
        return self.pushOnSelection != nil || self.selectionAction != nil
    }

    override func didSelectRowAction(_ row: Int) -> ActionHandler? {
        return self.selectionAction
    }

    override func viewControllerToPush(for row: Int) -> UIViewController? {
        return self.pushOnSelection
    }

    override func reuseIdentifier(for row: Int) -> String {
        return self.reuseIdentifier
    }

    override func configureCell(_ cell: UITableViewCell, for row: Int) {
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        self.cellConfiguration(cell)
        self.lastTitle = cell.textLabel?.text
        self.lastSubitle = cell.detailTextLabel?.text
    }

    override func title(for row: Int) -> String? {
        return self.lastTitle
    }

    override func subtitle(for row: Int) -> String? {
        return self.lastSubitle
    }
}
