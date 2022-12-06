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
    
    enum Tab: Int {
        case herd = 0
//        case chat = 1
        case notifications = 1
//        case profile = 3
        
        case myYaks = 2, myComments = 3
        case locations = 4
    }
    
    private lazy var feed: HerdViewController = .init()
    private lazy var notifications: NotificationsViewController = .init()
    private lazy var locations: MapViewController = .init()
    
    private lazy var posts: MyPostsViewController = .init(title: "My Yaks") { callback in
        YYClient.current.getMyRecentYaks(completion: callback)
    }
    private lazy var comments: MyCommentsViewController = .init(title: "My Comments") { callback in
        YYClient.current.getMyComments(completion: callback)
    }
    
//    private lazy var profile: TTProfileViewController = .init()
//    private lazy var settings: TTSettingsViewController = .init()
    
    private var ready: Bool = false
    
    fileprivate var currentNavigation: TTNavigationController {
        return self.selectedViewController as! TTNavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = .fullScreen
        self.delegate = self

        self.viewControllers = [
            self.feed, self.notifications,
            self.posts, self.comments,
            self.locations,
//            UIViewController.inNavigation(),
//            TTProfileViewController.inNavigation()
        ].map { TTNavigationController(rootViewController: $0) }

        let tabs: [(image: String, title: String)] = [
            ("newspaper.fill", "Herd"),
            ("app.badge.fill", "Notifications"),
            
            ("signpost.right.fill", "Posts"),
            ("quote.bubble.fill", "Comments"),
            
            ("map.fill", "Locations"),
            ("message.fill", "Chat"),
            ("person.crop.circle", "Profile"),
            ("gear", "Settings"),
        ]

        for (tab, item) in zip(tabs, self.tabBar.items!) {
            item.image = UIImage(systemName: tab.image)
            // item.selectedImage = UIImage(systemName: "\(tab.image).fill")
            item.title = tab.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LoginController(host: self, client: .current).requireLogin { host in
            host.feed.refresh()
            host.notifications.refresh()
            host.posts.refresh()
            host.comments.refresh()
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func focusTab(_ tab: TabBarController.Tab, then doSomething: ((TTNavigationController) -> Void)? = nil) {
        self.selectedIndex = tab.rawValue
        
        doSomething?(self.currentNavigation)
    }
}
