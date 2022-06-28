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
    private var callback: ((_ status: Bool) -> Void)? = nil
    
    private var accessGranted: Bool {
        self.permission.authorizationStatus.granted
    }
    
    private override init() {
        super.init()
        self.permission.delegate = self
    }
    
    static func requireLocation(callback: @escaping (_ status: Bool) -> Void) {
        if shared.accessGranted {
            // User granted
            callback(true)
        } else if shared.permission.authorizationStatus.undetermined {
            // User never prompted
            shared.callback = callback
            shared.permission.requestWhenInUseAuthorization()
        } else {
            // User prompted and denied
            callback(false)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.callback?(self.accessGranted)
    }
    
    static var location: CLLocation {
        return shared.permission.location!
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
