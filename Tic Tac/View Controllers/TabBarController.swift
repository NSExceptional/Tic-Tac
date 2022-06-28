//
//  TabBarController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import UIKit
import TBAlertController
import YakKit

@objcMembers
class TabBarController: UITabBarController {
    private lazy var feed: HerdViewController = .init()
//    private lazy var notifications: TTNotificationsViewController = .init()
//    private lazy var profile: TTProfileViewController = .init()
//    private lazy var settings: TTSettingsViewController = .init()
    
    private var ready: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = .fullScreen

        self.viewControllers = [
            self.feed,
//            TTNotificationsViewController.inNavigation(),
//            UIViewController.inNavigation(),
//            TTProfileViewController.inNavigation()
        ].map { UINavigationController(rootViewController: $0) }

        let tabs: [(image: String, title: String)] = [
            ("newspaper.fill", "Herd"),
            ("app.badge.fill", "Notifications"),
            ("message.fill", "Chat"),
            ("person.crop.circle", "Profile"),
            ("gear", "Settings"),
        ]

        for (tab, item) in zip(tabs, self.tabBar.items!) {
            item.image = UIImage(systemName: tab.image)
            item.title = tab.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LoginController(host: self, client: .current).requireLogin {
            self.feed.refresh()
        }
    }
}
