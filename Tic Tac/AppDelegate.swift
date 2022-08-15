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

extension UIApplication {
    var appDelegate: TTAppDelegate {
        return self.delegate as! TTAppDelegate
    }
}

@main @objc
class TTAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

    var window: UIWindow?
    
    var root: UIViewController {
        return self.window!.rootViewController!
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: LaunchOptions?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = TabBarController()
        self.window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        FLEXManager.shared.showExplorer()
        self.setupFLEX()
        
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    NSLog("🟦 UNUserNotificationCenter granted")
                } else {
                    NSLog("🛑 UNUserNotificationCenter denied: \(error?.localizedDescription ?? "nil")")
                }
            }
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
        
        let fakeToken = "4F142D1D01594167D0B40DC2592E7990978A575A850B70DA63C81A2670F6B24B".data(using: .utf8)!
        Auth.auth().setAPNSToken(fakeToken, type: .prod)
    }
    
    func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completion: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("🟦 Did Receive Background Notification: \(userInfo)");
        
        if Auth.auth().canHandleNotification(userInfo) {
            return completion(.noData)
        }
    }
    
    /// When app receives notification initially
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        TBAlert.make({ make in
            make.title("Received Notification")
                .message(notification.request.content.title)
                .message("\n")
                .message(notification.request.content.subtitle)
                .button("Dismiss")
        }, style: .alert, showFrom: self.window!.rootViewController!)
    }
    
    /// When user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        TBAlert.make({ make in
            make.title("Notification Tapped")
                .message("Titile: \(response.notification.request.content.title)")
                .message("\n")
                .message("Subtitle: \(response.notification.request.content.subtitle)")
                .message("\n")
                .message("Body: \(response.notification.request.content.body)")
                .button("Dismiss")
        }, style: .alert, showFrom: self.window!.rootViewController!)
    }
}

