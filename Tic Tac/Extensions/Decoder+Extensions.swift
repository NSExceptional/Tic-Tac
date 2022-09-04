//
//  Decoder+Extensions.swift
//  MoviePassKit
//
//  Created by Tanner on 12/3/17.
//

import Foundation

extension KeyedDecodingContainer {
    func value<T: Decodable>(for key: Key) -> T? {
        return try? self.decode(T.self, forKey: key)
    }

    subscript<T: Codable>(key: Key) -> T! {
        get {
            return self.value(for: key)
        }
    }
}
