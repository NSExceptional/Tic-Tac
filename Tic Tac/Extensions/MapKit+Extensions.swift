//
//  MapKit+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/16/22.
//

import MapKit

class TTPinAnnotation: MKPointAnnotation {
    enum PinType: Equatable {
        case unsaved
        case favorited(SavedLocation)
    }
    
    let type: PinType
    
    init(type: PinType, coordinate: CLLocationCoordinate2D) {
        self.type = type
        super.init()
        self.coordinate = coordinate
        
        switch type {
            case .unsaved:
                self.title = "Add to Favorites"
            case .favorited(let location):
                self.title = location.name
        }
    }
}

extension MKMapView {
    func register(view: MKAnnotationView.Type) {
        self.register(view, forAnnotationViewWithReuseIdentifier: NSStringFromClass(view))
    }
    
    func dequeueAnnotationView<T: MKAnnotationView>(for annotation: MKAnnotation) -> T {
        let identifier = NSStringFromClass(T.self)
        let view = self.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! T
        view.annotation = annotation
        
        return view
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (l: CLLocationCoordinate2D, r: CLLocationCoordinate2D) -> Bool {
        return l.latitude == r.latitude && l.longitude == r.longitude
    }
}
