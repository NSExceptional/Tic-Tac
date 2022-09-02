//
//  Context.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 9/1/22.
//

import YakKit

protocol ContextualHost: AnyObject {
    var presentingViewController: UIViewController? { get }
    var navigationController: UINavigationController? { get }
    
    func dismissSelf()
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
    func presentError(_ error: Error, title: String)
}

extension UIViewController: ContextualHost {
    struct Context: YakContext {
        unowned let host: ContextualHost
        var origin: YakDataOrigin = .organic
        var loading: Bool = false
    }
}

enum YakDataOrigin {
    /// I.E. yaks from a single herd, or comments from a single yak
    case organic
    /// I.E. yaks or comments from a single user
    case userProfile
}

/// Context for a yak (well, a post or comment)
protocol YakContext {
    
    var host: ContextualHost { get }
    
    /// How the content of this data source originated.
    /// An inorganic origin may affect the apperance and behavior of cells.
    var origin: YakDataOrigin { get }
    
    /// Whether the yak content is still being loaded
    var loading: Bool { get }
    
    var client: YYClient { get }
}

extension YakContext {
    var client: YYClient { .current }
}
