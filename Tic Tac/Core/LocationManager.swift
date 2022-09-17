//
//  LocationManager.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import Foundation
import CoreLocation
import TBAlertController

extension CLAuthorizationStatus {
    var granted: Bool {
        switch self {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
        }
    }
    
    var undetermined: Bool {
        return self == .notDetermined
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private static let shared: LocationManager = .init()
    
    private let permission: CLLocationManager = .init()
    private var updatingLocation: Bool = false
    private var authorizationCallback: ((_ status: Bool) -> Void)? = nil
    private var locationUpdateCallback: ((_ latestLocation: CLLocation) -> Void)? = nil
    
    private var accessGranted: Bool {
        self.permission.authorizationStatus.granted
    }
    
    private override init() {
        super.init()
        self.permission.delegate = self
        self.permission.pausesLocationUpdatesAutomatically = true
        self.permission.distanceFilter = 1000 // Only update every kilometer
        self.permission.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    static func requireLocation(callback: @escaping (_ status: Bool) -> Void) {
        if shared.accessGranted {
            // User granted
            callback(true)
        } else if shared.permission.authorizationStatus.undetermined {
            // User never prompted
            shared.authorizationCallback = callback
            shared.permission.requestWhenInUseAuthorization()
        } else {
            // User prompted and denied
            callback(false)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationCallback?(self.accessGranted)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Self.shared.locationUpdateCallback?(location)
    }
    
    static var location: CLLocation {
        return shared.permission.location!
    }
    
    static func observeLocation(callback: ((_ latestLocation: CLLocation) -> Void)?) {
        shared.locationUpdateCallback = callback
        
        if shared.updatingLocation, let location = shared.permission.location {
            callback?(location)
        }
        else {
            shared.permission.startUpdatingLocation()
        }
    }
}

extension LocationManager {
    static func presentLocationPermissionWarning(from host: UIViewController, onDismiss: (() -> Void)?) {
        TBAlert.make({ make in
            make.title("Location Required")
                .message("Enable Location Services for Tic Tac in Settings")
            make.button("Settings").preferred().handler { _ in
                self.openLocationSettings()
                onDismiss?()
            }
            
        }, showFrom: host)
    }
    
    static func openLocationSettings() {
        let bundle = Bundle.main.bundleIdentifier!
        let urlstring = UIApplication.openSettingsURLString
        let url = URL(string: "\(urlstring)&path=LOCATION/\(bundle)")!
        UIApplication.shared.open(url)
    }
}
