//
//  YakKit+Swift.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/23/22.
//

import Foundation
import YakKit

extension YYClient {
    private func convertToResult<T>(_ array: [Any]?, _ error: Error?) -> Result<[T], Error> {
        switch (array, error) {
            case (.some(let array), nil):
                return .success(array as! [T])
            case (nil, .some(let error)):
                return .failure(error)
            default:
                fatalError()
        }
    }
    
    func getLocalYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
    
    func getLocalHotYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalHotYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
    
    func getLocalTopYaks(completion: @escaping (Result<[YYYak], Error>) -> Void) {
        self.getLocalTopYaks_tuple { (a, e) in
            completion(self.convertToResult(a, e))
        }
    }
}
