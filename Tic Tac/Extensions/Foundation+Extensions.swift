//
//  Foundation+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/14/22.
//

import Foundation

extension NSException {
    static func raise(name: NSExceptionName, message: String) -> Never {
        self.raise(name, format: message, arguments: getVaList([]))
        fatalError()
    }
}
