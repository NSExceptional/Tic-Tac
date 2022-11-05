//
//  MapViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/14/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    private lazy var card = CardView(title: "Favorites")
    private var cardDidAppear = false
    
    override func loadView() {
        let map = MKMapView()
        map.showsAppleLogo = false
        
        self.view = map
        
        self.card.frame = map.bounds
        self.view.addSubview(self.card)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Location"
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
}
