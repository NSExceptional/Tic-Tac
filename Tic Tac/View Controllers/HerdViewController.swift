//
//  HerdViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit
import YakKit

class HerdViewController: FilteringTableViewController<YYYak> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableRefresh = true
    }
}
