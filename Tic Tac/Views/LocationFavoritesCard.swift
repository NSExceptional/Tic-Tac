//
//  LocationFavoritesCard.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import UIKit

class LocationFavoritesCard: CardView, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView = UITableView()
    
    private lazy var favorites = self.favoritesCoordinator.getValue()
    private var favoritesCoordinator: PlistCoordinator<[SavedLocation]> = .init(
        in: .documents, named: "Favorites", default: []
    )
    
    @Defaults(\.selectedLocation) private var selectedLocationName: String?
    private var selectedLocation: UserLocation = LocationManager.locationType {
        willSet { LocationManager.locationType = newValue }
    }
    
    /// Don't use any other inits; it's so stupid that I have to write this comment
    /// instead of the compiler helping me, but it makes it impossible to disable
    /// previous initializers...
    convenience init() {
        self.init(title: "Favorites")
        
        self.tableView.frame = self.contentView.bounds
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.tableView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(cell: FavoriteLocationCell.self)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = self.favorites[indexPath.row]
        let cell: FavoriteLocationCell = tableView.dequeueCell(for: indexPath)
        
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = "\(location.location)"
        
        return cell
    }
    
    /// Allow deleting favorites
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        // Remove favorite, update plist
        let removed = self.favorites.remove(at: indexPath.row)
        // TODO: error handling
        try? self.favoritesCoordinator.write(self.favorites)
        
        // Remove row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Update selected location if we remove the currently selected location
        if let selectedLocationName = self.selectedLocationName, removed.name == selectedLocationName {
            self.selectedLocation = .current
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
}
