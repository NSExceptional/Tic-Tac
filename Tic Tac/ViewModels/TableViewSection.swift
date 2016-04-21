//
//  TableViewSection.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

// MARK: TableViewSection

/// An abstract base class for table view sections.
///
/// Many properties or methods here return nil or some logical equivalent by default.
/// Even so, most of the methods with defaults are intended to be overriden by subclasses.
/// Some methods are not implemented at all and MUST be implemented by a subclass.
@objcMembers
class TableViewSection: NSObject {
    typealias ActionHandler = (UIViewController) -> Void
    
    static var defaultReuseID = "TableViewSection.defaultReuseID"
    
    private weak var tableView: UITableView?
    private var sectionIndex: Int = 0

    // MARK: - Data

    /// A title to be displayed for the custom section.
    /// Subclasses may override.
    var title: String? = nil
    
    /// The number of rows in this section. Subclasses must override.
    /// This should not change until \c filterText is changed or \c reloadData is called.
    var numberOfRows: Int {
        return 0
    }
    
    /// A list of cells to register for reuse, using the class name as the identifier.
    /// Subclasses \e may override this as necessary, but are not required to.
    /// @return nil by default.
    var reusableCellRegistry: [UITableViewCell.Type]? {
        return nil
    }
    
    /// The section should filter itself based on the contents of this property
    /// as it is set. If it is set to nil or an empty string, it should not filter.
    /// Subclasses should override or observe this property and react to changes.
    ///
    /// It is common practice to use two arrays for the underlying model:
    /// One to hold all rows, and one to hold unfiltered rows. When \c setFilterText:
    /// is called, call \c super to store the new value, and re-filter your model accordingly.
    var filterText: String?

    func configureCell(_ cell: UITableViewCell, for row: Int) { }

    /// Provides an avenue for the section to refresh data or change the number of rows.
    ///
    /// This is called before reloading the table view itself. If your section pulls data
    /// from an external data source, this is a good place to refresh that data entirely.
    /// If your section does not, then it might be simpler for you to just override
    /// \c setFilterText: to call \c super and call \c reloadData.
    func reloadData() { }

    /// Like \c reloadData, but optionally reloads the table view section
    /// associated with this section object, if any. Do not override.
    /// Do not call outside of the main thread.
    final func reloadData(_ updateTable: Bool = false) {
        self.reloadData()
        if updateTable {
            let index = NSIndexSet(index: self.sectionIndex)
            self.tableView?.reloadSections(index as IndexSet, with: .none)
        }
    }

    /// Provide a table view and section index to allow the section to efficiently reload
    /// its own section of the table when something changes it. The table reference is
    /// held weakly, and subclasses cannot access it or the index. Call this method again
    /// if the section numbers have changed since you last called it.
    func setTable(_ tableView: UITableView, section index: Int) {
        self.tableView = tableView
        self.sectionIndex = index
    }

    // MARK: - Row Selection

    /// Whether the given row should be selectable, such as if tapping the cell
    /// should take the user to a new screen or trigger an action.
    /// Subclasses \e may override this as necessary, but are not required to.
    /// @return \c NO by default
    func canSelectRow(_ row: Int) -> Bool {
        return false
    }

    /// An action "future" to be triggered when the row is selected, if the row
    /// supports being selected as indicated by \c canSelectRow:. Subclasses
    /// must implement this in accordance with how they implement \c canSelectRow:
    /// if they do not implement \c viewControllerToPushfor:
    /// @return This returns \c nil if no view controller is provided by
    /// \c viewControllerToPushfor: — otherwise it pushes that view controller
    /// onto \c host.navigationController
    func didSelectRowAction(_ row: Int) -> ActionHandler? {
        if let toPush = self.viewControllerToPush(for: row) {
            return { host in
                host.navigationController?.pushViewController(toPush, animated: true)
            }
        }

        return nil
    }

    /// A view controller to display when the row is selected, if the row
    /// supports being selected as indicated by \c canSelectRow:. Subclasses
    /// must implement this in accordance with how they implement \c canSelectRow:
    /// if they do not implement \c didSelectRowAction:
    /// @return \c nil by default
    func viewControllerToPush(for row: Int) -> UIViewController? {
        return nil
    }

    /// Called when the accessory view's detail button is pressed.
    /// @return \c nil by default.
    func didPressInfoButtonAction(_ row: Int) -> ActionHandler? {
        return nil
    }

    // MARK: - Cell Configuration

    /// Provide a reuse identifier for the given row. Subclasses should override.
    ///
    /// Custom reuse identifiers should be specified in \c reusableCellRegistry.
    /// You may return any of the identifiers in \c TableView.h
    /// without including them in the \c reusableCellRegistry.
    /// @return \c kDefaultCell by default.
    func reuseIdentifier(for row: Int) -> String {
        return Self.defaultReuseID
    }

    // MARK: - Context Menus

    /// By default, this is the title of the row.
    /// @return The title of the context menu, if any.
    func menuTitle(for row: Int) -> String? {
        let title = self.title(for: row)
        let subtitle = self.menuSubtitle(for: row)

        if subtitle.count != 0 {
            return """
                \(title ?? "")

                \(subtitle)
                """
        }

        return title
    }

    /// Protected, not intended for public use. \c menuTitlefor:
    /// already includes the value returned from this method.
    /// 
    /// By default, this returns \c @"". Subclasses may override to
    /// provide a detailed description of the target of the context menu.
    func menuSubtitle(for row: Int) -> String {
        return ""
    }

    /// The context menu items, if any. Subclasses may override.
    /// By default, only inludes items for \c copyMenuItemsfor:.
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

    /// Subclasses may override to return a list of copiable items.
    ///
    /// Every two elements in the list compose a key-value pair, where the key
    /// should be a description of what will be copied, and the values should be
    /// the strings to copy. Return an empty string as a value to show a disabled action.
    func copyMenuItems(for row: Int) -> [(label: String, value: String)] {
        return []
    }

    // MARK: - External Convenience

    /// For use by whatever view controller uses your section. Not required.
    /// @return An optional title.
    func title(for row: Int) -> String? {
        return nil
    }

    /// For use by whatever view controller uses your section. Not required.
    /// @return An optional subtitle.
    func subtitle(for row: Int) -> String? {
        return nil
    }
}
