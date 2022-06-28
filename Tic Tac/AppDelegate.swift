//
//  AppDelegate.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import UserNotifications
import FLEX
import FirebaseAuth
import FirebaseCore
import TBAlertController

@main @objc
class TTAppDelegate: UIResponder, UIApplicationDelegate {
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

    var window: UIWindow?
    
    var root: UIViewController {
        return self.window!.rootViewController!
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: LaunchOptions?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = TabBarController()
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        self.setupFLEX()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            NSLog("🟦 UNUserNotificationCenter granted")
        }
        
        return true
    }
    
    func setupFLEX() {
        let tap = UITapGestureRecognizer(target: FLEXManager.shared, action: #selector(FLEXManager.toggleExplorer))
        tap.numberOfTouchesRequired = 3
        self.window?.addGestureRecognizer(tap)
    }
    
    // MARK: Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token: UInt = deviceToken.read()
        NSLog("🟦 Did Register with APNS: \(token)");
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }
    
    func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completion: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("🟦 Did Receive Background Notification: \(userInfo)");
        
        if Auth.auth().canHandleNotification(userInfo) {
            completion(.noData)
        }
    }
}

