//
//  MapViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/14/22.
//

import UIKit
import MapKit
import TBAlertController

@objcMembers
class MapViewController: UIViewController, MKMapViewDelegate {
    private lazy var card = LocationFavoritesCard()
    private var cardDidAppear = false
    private lazy var mapView = MKMapView()
    
    private var favoritePins: [MKAnnotation] = []
    
    override func loadView() {
        super.loadView()
        
        self.mapView.showsAppleLogo = false
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.card.frame = self.view.bounds
        self.mapView.frame = self.view.bounds
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.card)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Location"
        
        self.mapView.register(view: MKPinAnnotationView.self)
        self.reloadFavoritePins()
        
        // Add gesture to drop a pin to add a favorite
        self.mapView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self, action: #selector(handleDropPinGesture(_:))
        ))
        
        LocationManager.observeFavorites { updatedList in
            self.reloadFavoritePins()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if !self.cardDidAppear {
            self.card.frame.size.height = self.view.frame.height / 2
            self.card.frame.origin.y = self.view.center.y
            self.card.minimize()
        }
        
        self.cardDidAppear = true
    }
    
    private func reloadFavoritePins() {
        self.favoritePins.forEach(self.mapView.removeAnnotation(_:))
        
        self.favoritePins = LocationManager.favorites.map { favorite in
            return TTPinAnnotation(
                type: .favorited(favorite),
                coordinate: favorite.location.coordinate
            )
        }
        
        self.favoritePins.forEach(self.mapView.addAnnotation(_:))
    }
    
    func removePinAndAddFavorite(_ annotation: TTPinAnnotation) {
        self.mapView.removeAnnotation(annotation)
        self.promptForNewFavoriteName(at: annotation.coordinate)
    }
    
    func removePin(_ annotation: TTPinAnnotation, andFavorite location: SavedLocation) {
        self.mapView.removeAnnotation(annotation)
        LocationManager.removeFavorite(location)
    }
    
    func promptForNewFavoriteName(at coordinate: CLLocationCoordinate2D, tryAgain: Bool = false) {
        TBAlert.make({ make in
            make.title("Name This Location")
            make.message("Give this favorite location a unique name.")
            if tryAgain {
                make.message("\n\nThe name you supplied was not unique, try again.")
            }
            
            make.configuredTextField { field in
                field.placeholder = "Blue Mountain State"
                field.autocapitalizationType = .words
                field.autocorrectionType = .yes
                field.textContentType = .location
                field.returnKeyType = .done
            }
            
            make.button("Cancel")
            make.button("Save").preferred().handler { strings in
                let name = strings.first!
                if !LocationManager.addFavorite(with: name, at: coordinate) {
                    self.promptForNewFavoriteName(at: coordinate, tryAgain: true)
                }
            }
        }, showFrom: self)
    }
    
    // MARK: MKMapView events
    
    @objc func handleDropPinGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Remove existing pin, if any
        for pin in self.mapView.annotations.compactMap({ $0 as? TTPinAnnotation }) {
            if pin.type == .unsaved {
                self.mapView.removeAnnotation(pin)
                break
            }
        }
        
        let location = gesture.location(in: self.mapView)
        let coordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        // Add new temporary pin
        let annotation = TTPinAnnotation(type: .unsaved, coordinate: coordinate)
        self.mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TTPinAnnotation else { return nil }
        
        let pinView: MKPinAnnotationView = mapView.dequeueAnnotationView(for: annotation)
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        
        switch annotation.type {
            case .favorited(_):
                pinView.rightCalloutAccessoryView = UIButton(symbol: "star.fill")
            case .unsaved:
                pinView.rightCalloutAccessoryView = UIButton(symbol: "star")
                
                // Show callout right away
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.333) {
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
        }
        
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? TTPinAnnotation else { return }

        // Add or remove a favorite location
        switch annotation.type {
            case .unsaved:
                self.removePinAndAddFavorite(annotation)
            case .favorited(let location):
                self.removePin(annotation, andFavorite: location)
        }
    }
}
