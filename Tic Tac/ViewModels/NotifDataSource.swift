//
//  NotifDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/10/22.
//

import UIKit
import YakKit

class NotifDataSource: ModelDataSource<YYNotification, NotificationCell> {
    override func canSelectRow(_ row: Int) -> Bool {
        return true
    }
    
    override func viewControllerToPush(for row: Int) -> UIViewController? {
        return CommentsViewController(from: self.rows[row])
    }
}
