//
//  MapViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/14/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    override func loadView() {
        self.view = MKMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Location"
    }
}
