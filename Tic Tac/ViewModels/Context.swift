//
//  Context.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 9/1/22.
//

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
