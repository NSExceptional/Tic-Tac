//
//  FavoriteLocationCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/6/22.
//

import UIKit

class FavoriteLocationCell: BaseCell {
    override class var preferredStyle: CellStyle { .subtitle }
    
    override func setup() {
        self.textLabel?.font = .preferredFont(forTextStyle: .headline)
        self.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        
        self.detailTextLabel?.textColor = .secondaryLabel
    }
}
