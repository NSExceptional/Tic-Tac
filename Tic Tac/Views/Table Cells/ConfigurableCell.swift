//
//  ConfigurableCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/10/22.
//

import Foundation
import YakKit

protocol ConfigurableCell: AutoLayoutCell {
    associatedtype Model: YYThing
    
    @discardableResult
    func configure(with model: Model, client: YYClient) -> Self
}
