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
    
    var title: String? = nil
    var filterText: String? = nil
    var sectionIndex: Int = 0
    var pushOnSelection: UIViewController? = nil
    var selectionAction: ActionHandler? = nil
    /// Called to determine whether the single row should display itself or not.
    var filterMatcher: ((_ filterText: String) -> Bool)? = nil
    private var reuseIdentifier: String
    private var cellConfiguration: ((UITableViewCell) -> Void)
    private var lastTitle: String? = nil
    private var lastSubitle: String? = nil

    /// @param reuseIdentifier if nil, kDefaultCell is used.

    // MARK: - Public

    init(sectionTitle: String?, reuseIdentifier: String = "\(UITableViewCell.self)",
         cellConfiguration: @escaping (UITableViewCell) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        self.cellConfiguration = cellConfiguration
        self.title = sectionTitle
    }

    // MARK: - Overrides

    var numberOfRows: Int {
        if let filter = self.filterMatcher, let text = self.filterText, !text.isEmpty {
            return filter(text) ? 1 : 0
        }

        return 1
    }

    func canSelectRow(_ row: Int) -> Bool {
        return self.pushOnSelection != nil || self.selectionAction != nil
    }

    func didSelectRowAction(_ row: Int) -> ActionHandler? {
        return self.selectionAction
    }

    func viewControllerToPush(for row: Int) -> UIViewController? {
        return self.pushOnSelection
    }

    func reuseIdentifier(for row: Int) -> String {
        return self.reuseIdentifier
    }

    func configureCell(_ cell: UITableViewCell, for row: Int) {
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        self.cellConfiguration(cell)
        self.lastTitle = cell.textLabel?.text
        self.lastSubitle = cell.detailTextLabel?.text
    }
    
    func cell(_ table: UITableView, for ip: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: ip)
        self.configureCell(cell, for: ip.row)
        return cell
    }

    func title(for row: Int) -> String? {
        return self.lastTitle
    }

    func subtitle(for row: Int) -> String? {
        return self.lastSubitle
    }
}
