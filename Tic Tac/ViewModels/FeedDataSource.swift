//
//  FeedDataSource.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/22/22.
//

import UIKit
import YakKit

class FeedDataSource: VotableDataSource<YYYak, YakCell> {
    override func canSelectRow(_ row: Int) -> Bool {
        return true
    }
    
    override func viewControllerToPush(for row: Int) -> UIViewController? {
        return CommentsViewController(for: self.rows[row])
    }
}
