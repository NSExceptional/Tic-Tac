//
//  ProfilesViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/12/22.
//

import UIKit
import YakKit

class ProfilesViewController: UITableViewController {
    
    enum Section: Int {
        case currentUser, data
        
        static let count = 2
        
        var count: Int {
            switch self {
                case .currentUser:
                    return 2
                case .data:
                    return 2
            }
        }
        
        enum UserRows: Int {
            case user, emojis
        }
        
        enum DataRows: Int {
            case posts, comments
        }
    }
    
    private var user: YYUser? = YYClient.current.currentUser
    private lazy var context = Context(host: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        self.tableView.register(cell: UserProfileCell.self)
        self.tableView.register(cell: UITableViewCell.self)
        
        // For updating the table when the user changes,
        // and keeping it disabled until we even have a user
        YYClient.observeCurrentUser { user in
            self.user = user
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue: section)!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = self.user else {
            fatalError("Trying to display user profile without user object")
        }
        
        switch Section(rawValue: indexPath.section)! {
            case .currentUser:
                switch Section.UserRows(rawValue: indexPath.row)! {
                    case .user:
                        return tableView.dequeueCell(UserProfileCell.self, for: indexPath)
                            .configure(with: user, context: self.context)
                    case .emojis:
                        fatalError()
                }
            case .data:
                switch Section.DataRows(rawValue: indexPath.row)! {
                    case .posts:
                        fatalError()
                    case .comments:
                        fatalError()
                }
        }
    }
}
