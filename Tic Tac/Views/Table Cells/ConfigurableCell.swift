//
//  ConfigurableCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/10/22.
//

import Foundation
import YakKit

enum CellDataOrigin {
    /// I.E. yaks from a single herd, or comments from a single yak
    case organic
    /// I.E. yaks or comments from a single user
    case userProfile
}

protocol CellContext {
    var origin: CellDataOrigin { get }
}

protocol ConfigurableCell: AutoLayoutCell {
    associatedtype Model: YYThing
    
    @discardableResult
    func configure(with model: Model, context: CellContext, client: YYClient) -> Self
}
