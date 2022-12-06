//
//  LocationManager+Favorites.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/16/22.
//

import Foundation

extension LocationManager {
    
    // MARK: Private
    
    private static var favoritesSubscribers = UnkeyedSubscriptionStore<[SavedLocation]>()
    
    private static let favoritesCoordinator: PlistCoordinator<[SavedLocation]> = .init(
        in: .documents, named: "Favorites", default: []
    )
    
    private static func notifySubscribers() {
        self.favoritesSubscribers.notifyAll(of: self.favorites)
    }
    
    // MARK: Public
    
    typealias FavoritesSubscription = SubscriptionStore.Subscription<[SavedLocation]>
    
    static var favorites: [SavedLocation] { favoritesCoordinator.getValue() }
    
    static func setFavorites(_ favorites: [SavedLocation]) {
        try? favoritesCoordinator.write(favorites)
        // TODO: add event types for favorites (added, removed, etc)
//        self.notifySubscribers()
    }
    
    static func addFavorite(with name: String, at coordinate: CLLocationCoordinate2D) -> Bool {
        // Check if we already have a favorite with the given name
        guard self.favorites.first(where: { $0.name == name }) == nil else {
            return false
        }
        
        // Add favorite
        var newFavorites = favorites
        newFavorites.append(SavedLocation(name: name, location: coordinate))
        // Save favorites
        try? favoritesCoordinator.write(newFavorites)
        
        defer { self.notifySubscribers() }
        
        return true
    }
    
    static func removeFavorite(_ location: SavedLocation) {
        var newFavorites = favorites
        newFavorites.remove(location)
        
        try? favoritesCoordinator.write(newFavorites)
        
        self.notifySubscribers()
    }
    
    @discardableResult
    static func removeFavorite(at index: Int) -> SavedLocation {
        var newFavorites = favorites
        let removed = newFavorites.remove(at: index)
        
        try? favoritesCoordinator.write(newFavorites)
        
        defer { self.notifySubscribers() }
        
        return removed
    }
    
    static func observeFavorites(_ subscription: @escaping FavoritesSubscription) {
        favoritesSubscribers.add(subscription)
    }
}
