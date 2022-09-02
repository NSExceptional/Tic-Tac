//
//  ConfigurableCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/10/22.
//

import Foundation
import YakKit

enum YakDataOrigin {
    /// I.E. yaks from a single herd, or comments from a single yak
    case organic
    /// I.E. yaks or comments from a single user
    case userProfile
}

/// Context for a yak (well, a post or comment)
protocol YakContext {
    var origin: YakDataOrigin { get }
    var client: YYClient { get }
}

extension YakContext {
    var client: YYClient { .current }
}

protocol ConfigurableCell: AutoLayoutCell {
    associatedtype Model: YYThing
    
    @discardableResult
    func configure(with model: Model, context: YakContext) -> Self
}
