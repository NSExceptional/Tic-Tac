//
//  LocationManager.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import Foundation
import CoreLocation
import TBAlertController
import YakKit

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
    typealias LocationInfo = (location: CLLocation, name: String?)
    typealias LocationSubscriber = SubscriptionStore.Subscriber<LocationInfo>
    private static let shared: LocationManager = .init()
    
    private let permission: CLLocationManager = .init()
    private var updatingLocation: Bool = false
    private var authorizationCallback: ((_ status: Bool) -> Void)? = nil
    private var locationObservers = UnkeyedSubscriptionStore<LocationInfo>()
    
    private var accessGranted: Bool {
        self.permission.authorizationStatus.granted
    }
    
    private override init() {
        super.init()
        self.permission.delegate = self
        self.permission.pausesLocationUpdatesAutomatically = true
        self.permission.distanceFilter = 1000 // Only update every kilometer
        self.permission.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Load the last selected location override
        if let lastChosenLocationName = self.selectedLocationName {
            if let locationOverride = LocationManager.favorites.first(where: { $0.name == lastChosenLocationName }) {
                self.locationType = .override(locationOverride)
            }
            else {
                self.selectedLocationName = nil
            }
        }
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
    
    @Defaults(\.selectedLocation) var selectedLocationName: String?
    
    static var locationType: UserLocation {
        get { shared.locationType }
        set { shared.locationType = newValue }
    }
    var locationType: UserLocation = .current {
        didSet {
            // Store selected location name in user defaults
            switch locationType {
                case .current:
                    self.selectedLocationName = nil
                case .override(let location):
                    self.selectedLocationName = location.name
            }
            
            // Post location update notification
            if let location = self.location {
                // Manually update YYClient FIRST to ensure it is always first
                YYClient.current.location = location
                
                // Now, notify observers
                let newLocationData = (location, self.selectedLocationName)
                self.locationObservers.notifyAll(of: newLocationData)
            }
        }
    }
    
    static var location: CLLocation? { shared.location }
    var location: CLLocation? {
        switch self.locationType {
            case .current:
                return self.permission.location
            case .override(let location):
                return .init(location.location.coordinate)
        }
    }
    
    @discardableResult
    static func observeLocation(callback: @escaping (LocationInfo) -> Void) -> LocationSubscriber {
        let sub = shared.locationObservers.add(callback)
        
        if shared.updatingLocation, let location = shared.location {
            callback((location, shared.selectedLocationName))
        }
        else {
            shared.updatingLocation = true
            shared.permission.startUpdatingLocation()
        }
        
        return sub
    }
    
    static func removeObserver(_ observer: LocationSubscriber?) {
        guard let observer = observer else { return }
        shared.locationObservers.remove(observer)
    }
    
    // MARK: Delegate methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationCallback?(self.accessGranted)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // No location?
        guard let location = locations.first else { return }
        
        if let knownLocation = self.permission.location?.coordinate {
            // Location did not change
            guard location.coordinate != knownLocation else { return }
        }
        
        self.locationObservers.notifyAll(of: (self.location ?? location, self.selectedLocationName))
    }
    
    // MARK: Unavailable methods
    
    @available(*, unavailable)
    override class func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        super.removeObserver(observer, forKeyPath: keyPath)
    }
    
    @available(*, unavailable)
    override class func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?) {
        super.removeObserver(observer, forKeyPath: keyPath, context: context)
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
