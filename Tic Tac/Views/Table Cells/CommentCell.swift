//
//  CommentCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/27/22.
//

import UIKit
import YakKit

class CommentCell: YakCell {
    typealias Model = YYComment
    
    override func setup() {
        super.setup()
        self.backgroundColor = .secondarySystemBackground
        self.yakView.title.font = .preferredFont(forTextStyle: .body)
        
        self.yakView.voteCounter?.stepperScale = .init(dx: 0.75, dy: 0.75)
    }
}
