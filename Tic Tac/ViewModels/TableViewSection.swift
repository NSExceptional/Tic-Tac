//
//  TableViewSection.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

// MARK: TableViewSection

/// A protocol for table view sections, with default implementations for many requirements.
///
/// Many properties or methods here return `nil` or some logical equivalent by default.
/// Even so, most of the requirements with defaults are intended to be implemented by conformers.
/// Some requirements are not implemented _at all_ and _**must**_ be implemented by a subclass.
protocol TableViewSection: AnyObject {
//    associatedtype Cell: UITableViewCell
    typealias ActionHandler = (UIViewController) -> Void
    
    var sectionIndex: Int { get set }

    // MARK: - Data

    /// A title to be displayed for the custom section.
    var title: String? { get }
    
    /// The number of rows in this section. Conformers must implement.
    /// This should not change until `filterText` is changed or `reloadData` is called.
    var numberOfRows: Int { get }
    
    /// A list of cells to register for reuse, using the class name as the identifier.
    /// Conformers \e may override this as necessary, but are not required to.
    /// - returns: `[UITableViewCell.self]` by default.
    var reusableCellRegistry: [UITableViewCell.Type] { get }
    
    /// The section should filter itself based on the contents of this property
    /// as it is set. If it is set to nil or an empty string, it should not filter.
    /// Conformers must implement this property.
    ///
    /// It is common practice to use two arrays for the underlying model:
    /// One to hold all rows, and one to hold unfiltered rows. When `setFilterText:`
    /// is called, call `super` to store the new value, and re-filter your model accordingly.
    var filterText: String? { get set }

    func cell(_ table: UITableView, for row: IndexPath) -> UITableViewCell

    /// Provides an avenue for the section to refresh data or change the number of rows.
    ///
    /// This is called before reloading the table view itself. If your section pulls data
    /// from an external data source, this is a good place to refresh that data entirely.
    /// If your section does not, then it might be simpler for you to just override
    /// `setFilterText:` to call `super` and call `reloadData`.
    func reloadData()

    /// Like `reloadData,` but optionally reloads the table view section
    /// associated with this section object, if any. Do not override.
    /// Do not call outside of the main thread.
    func reloadData(_ reloadTable: UITableView?)

    // MARK: - Row Selection

    /// Whether the given row should be selectable, such as if tapping the cell
    /// should take the user to a new screen or trigger an action.
    /// Conformers \e may override this as necessary, but are not required to.
    /// - returns: `NO` by default
    func canSelectRow(_ row: Int) -> Bool

    /// An action "future" to be triggered when the row is selected, if the row
    /// supports being selected as indicated by `canSelectRow:`. Conformers
    /// must implement this in accordance with how they implement `canSelectRow:`
    /// if they do not implement `viewControllerToPushfor:`
    /// - returns: This returns `nil` if no view controller is provided by
    /// `viewControllerToPushfor:` — otherwise it pushes that view controller
    /// onto `host.navigationController`
    func didSelectRowAction(_ row: Int) -> ActionHandler?

    /// A view controller to display when the row is selected, if the row
    /// supports being selected as indicated by `canSelectRow:`. Conformers
    /// must implement this in accordance with how they implement `canSelectRow:`
    /// if they do not implement `didSelectRowAction:`
    /// - returns: `nil` by default
    func viewControllerToPush(for row: Int) -> UIViewController?

    // MARK: - Cell Configuration

    /// Provide a reuse identifier for the given row. Conformers must implement.
    ///
    /// Custom reuse identifiers should be specified in `reusableCellRegistry`.
    /// You may return any of the identifiers in `TableView.h`
    /// without including them in the `reusableCellRegistry`.
    /// - returns: `kDefaultCell` by default.
    func reuseIdentifier(for row: Int) -> String

    // MARK: - Context Menus

    /// By default, this is the title of the row.
    /// - returns: The title of the context menu, if any.
    func menuTitle(for row: Int) -> String?

    /// The context menu items, if any. Conformers may override.
    /// By default, only inludes items for `copyMenuItemsfor:`.
    @available(iOS 13.0, *)
    func menuItems(for row: Int, sender: UIViewController) -> [UIMenuElement]

    /// Conformers may override to return a list of copiable items.
    ///
    /// Every two elements in the list compose a key-value pair, where the key
    /// should be a description of what will be copied, and the values should be
    /// the strings to copy. Return an empty string as a value to show a disabled action.
    func copyMenuItems(for row: Int) -> [(label: String, value: String)]
    
    // MARK: - Swipe Actions
    
    func leadingSwipeActions(for row: Int) -> [UIContextualAction]
    func trailingSwipeActions(for row: Int) -> [UIContextualAction]

    // MARK: - External Convenience

    /// For use by whatever view controller uses your section. Not required.
    /// - returns: An optional title.
    func title(for row: Int) -> String?

    /// For use by whatever view controller uses your section. Not required.
    /// - returns: An optional subtitle.
    func subtitle(for row: Int) -> String?
}

extension TableViewSection {
    var title: String? { nil }
    var reusableCellRegistry: [UITableViewCell.Type] { [UITableViewCell.self] }
    
    func reloadData() { }

    func reloadData(_ reloadTable: UITableView? = nil) {
        self.reloadData()
        if let table = reloadTable {
            let index = NSIndexSet(index: self.sectionIndex)
            table.reloadSections(index as IndexSet, with: .none)
        }
    }
    
    func canSelectRow(_ row: Int) -> Bool {
        return false
    }

    func didSelectRowAction(_ row: Int) -> ActionHandler? {
        if let toPush = self.viewControllerToPush(for: row) {
            return { host in
                host.navigationController?.pushViewController(toPush, animated: true)
            }
        }

        return nil
    }

    func viewControllerToPush(for row: Int) -> UIViewController? {
        return nil
    }

    func reuseIdentifier(for row: Int) -> String {
        return "\(UITableViewCell.self)"
    }

    func menuTitle(for row: Int) -> String? {
        return self.title(for: row)
    }

    @available(iOS 13.0, *)
    func menuItems(for row: Int, sender: UIViewController) -> [UIMenuElement] {
        let copyItems = self.copyMenuItems(for: row)

        if !copyItems.isEmpty {
            let numberOfActions = copyItems.count
            let collapseMenu = numberOfActions > 4
            let copyIcon = UIImage(systemName: "doc.on.doc")!

            let actions: [UIAction] = copyItems.map { pair in
                let title = collapseMenu ? pair.label : "Copy " + pair.label
                return UIAction(copyText: pair.value, title: title, disabled: pair.value.isEmpty)
            }

            let copyMenu = UIMenu.inline("Copy…", image: copyIcon, items: actions)
            return collapseMenu ? [copyMenu.collapsed] : [copyMenu]
        }

        return []
    }

    func copyMenuItems(for row: Int) -> [(label: String, value: String)] {
        return []
    }

    func title(for row: Int) -> String? {
        return nil
    }

    func subtitle(for row: Int) -> String? {
        return nil
    }
}

protocol DataSource: TableViewSection {
    associatedtype Model
    associatedtype Context
    
    init(rows: [Model])
    init(rows: [Model], config: Context)
}
