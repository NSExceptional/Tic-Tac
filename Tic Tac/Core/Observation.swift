//
//  Observation.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 11/25/22.
//

import Foundation

/// A utility class to manage event subscriptions, without having to dip into KVO
class SubscriptionStore {
    typealias Subscription<T> = (T) -> Void
    final class Subscriber<T> {
        let block: Subscription<T>
        
        fileprivate init(_ subscriber: @escaping Subscription<T>) {
            self.block = subscriber
        }
    }
}

class KeyedSubscriptionStore: SubscriptionStore {
    private var store: [String: [Any]] = [:]
    
    @discardableResult
    func add<T>(_ subscription: @escaping Subscription<T>, to key: String) -> Subscriber<T> {
        let sub = Subscriber(subscription)
        self.store[key, default: []].append(sub)
        return sub
    }
    
    func remove<T>(_ subscriber: Subscriber<T>, from key: String) {
        guard let idx = self.store[key, default: []].firstIndex(where: { element in
            subscriber === (element as! Subscriber<T>)
        }) else { return }
        
        self.store[key]?.remove(at: idx)
    }
    
    func notifyAll<T>(of object: T, withKey key: String) {
        self.store[key, default: []]
            .compactMap { $0 as? Subscriber<T> }
            .forEach { $0.block(object) }
    }
}

class UnkeyedSubscriptionStore<T>: SubscriptionStore {
    private var store: [Subscriber<T>] = []
    
    @discardableResult
    func add(_ subscription: @escaping Subscription<T>) -> Subscriber<T> {
        let sub = Subscriber(subscription)
        self.store.append(sub)
        return sub
    }
    
    func remove(_ subscriber: Subscriber<T>) {
        guard let idx = self.store.firstIndex(where: { element in
            subscriber === element
        }) else { return }
        
        self.store.remove(at: idx)
    }
    
    func notifyAll(of object: T) {
        for sub in self.store {
            sub.block(object)
        }
    }
}
