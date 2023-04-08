//
//  LocationFavoritesCard.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import UIKit

@objcMembers
class LocationFavoritesCard: CardView, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView = UITableView()
    
    private lazy var favorites = LocationManager.favorites
    
    @Defaults(\.selectedLocation) private var selectedLocationName: String?
    private var selectedLocation: UserLocation = LocationManager.locationType {
        willSet {
            // Update selected location on disk
            switch newValue {
                case .current:
                    self.selectedLocationName = nil
                case .override(let location):
                    self.selectedLocationName = location.name
            }
            
            // Notify location manager
            LocationManager.locationType = newValue
        }
    }
    
    init() {
        super.init(title: "Favorites")
        
        let button = UIButton(primaryAction: .init { [weak self] _ in
            self?.toggleEditing()
        })
        button.setTitle("Edit", for: .normal) // Bleh, observers don't run HERE
        self.titleAccessoryView = button
        
        self.tableView.frame = self.contentView.bounds
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.backgroundColor = .clear
        self.contentView.addSubview(self.tableView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(cell: FavoriteLocationCell.self)
        
        // Update favorites as they are added
        // TODO: better handle adding our own favorites to avoid a reload
        LocationManager.observeFavorites { updatedList in
            self.favorites = updatedList
            self.tableView.reloadData()
        }
    }
    
    @objc
    private func toggleEditing() {
        self.editing = !self.editing
    }
    
    @objc
    private var editing: Bool = false {
        willSet {
            let button = self.titleAccessoryView as! UIButton
            button.setTitle(newValue ? "Done" : "Edit", for: .normal)
            
            self.tableView.setEditing(newValue, animated: true)
            // This gesture gets in the way of reordering
            self.panGesture.isEnabled = !newValue
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoriteLocationCell = tableView.dequeueCell(for: indexPath)
        let location = self.favorites[indexPath.row]
        
        cell.location = location
        
        if let name = self.selectedLocationName, name == location.name {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    /// Allow deleting favorites
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        // Remove favorite
        let removed = LocationManager.removeFavorite(at: indexPath.row, notify: false)
        self.favorites = LocationManager.favorites
        
        // Remove row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Update selected location if we remove the currently selected location
        if let selectedLocationName = self.selectedLocationName, removed.name == selectedLocationName {
            self.selectedLocation = .current
        }
    }
    
    /// Allow reordering favorites
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt src: IndexPath, to dest: IndexPath) {
        let moved = self.favorites.remove(at: src.row)
        self.favorites.insert(moved, at: dest.row)
        
        // Reorder favorites
        LocationManager.setFavorites(self.favorites)
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // De-select previously selected row (or de-select this row)
        if let selectedName = self.selectedLocationName {
            // Find previous favorite index
            let idx = self.favorites.firstIndex { $0.name == selectedName }
            // If visible, uncheck it
            if let selectedIP = (tableView.indexPathsForVisibleRows ?? []).first(where: { $0.row == idx }) {
                tableView.cellForRow(at: selectedIP)?.accessoryType = .none
                // If we tapped the already selected row, dont' re-select it
                if selectedIP == indexPath {
                    self.selectedLocation = .current
                    return
                }
            }
        }
        
        // Add checkmark to the selected cell
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        // Update view state with newly selected name
        self.selectedLocation = .override(self.favorites[indexPath.row])
    }
}
