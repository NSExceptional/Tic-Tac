//
//  TTNavigationController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/20/22.
//

import UIKit

class TTNavigationController: UINavigationController {
    func popToRootViewControllerAnimated() {
        super.popToRootViewController(animated: true)
    }
    
    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        switch self.viewControllers.count {
            case 0: return nil
            case 1:
                if let tableVC = self.viewControllers.last as? TTTableViewController {
                    // Scroll top tableview to top on first tap
                    if !tableVC.isScrolledToTop {
                        tableVC.scrollToTop()
                    }
                    // Refresh on second tap
                    else {
                        tableVC.showRefreshControlAndRefresh()
                    }
                    
                    return nil
                }
            default:
                if let tableVC = self.viewControllers.last as? UITableViewController {
                    // Scroll top tableview to top on first tap
                    if !tableVC.isScrolledToTop {
                        tableVC.scrollToTop()
                    }
                    // Pop to root on next tap
                    else {
                        return super.popToRootViewController(animated: true)
                    }
                }
                else {
                    // No table views; pop to root
                    return self.popToRootViewController(animated: true)
                }
        }
        
        return nil
    }
}

private extension UITableViewController {
    var isScrolledToTop: Bool {
        return self.tableView.contentOffset == self.tableView.minContentOffset
    }
    
    func scrollToTop() {
        guard self.tableView.numberOfSections > 0, self.tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        
        self.tableView.setContentOffset(self.tableView.minContentOffset, animated: true)
    }
}
