//
//  Promise.swift
//  Tic Tac
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2021 Ryu Games. All rights reserved.
//

import Foundation

public typealias Promise<Value> = BasePromise<Value, Error>

/// A Promise is an object representing the eventual completion/failure of an asynchronous operation.
public final class BasePromise<Value, ErrorType: Error> {

    internal enum State<T, E> {
        case pending
        case resolved(T)
        case rejected(E)
    }

    internal var state: State<Value, ErrorType> = .pending
    internal var val: Value? {
        if case .resolved(let value) = self.state {
            return value
        }
        return nil
    }

    /// A `Then` block.
    public typealias Then = (Value) -> Void

    /// A `Catch` block.
    public typealias Catch = (ErrorType) -> Void

    /// An `Always` block.
    public typealias Always = () -> Void

    private var callback: Then? = nil
    private var errorCallback: Catch? = nil
    private var dispatchQueue: DispatchQueue? = nil

    /// Initailizes a new Promise.
    /// - Parameter dispatchQueue: The `DispatchQueue` to run the given Promise on.
    /// Defaults to `promiseQueue`.
    /// - Parameter executor: The `Then` and `Catch` blocks.
    /// - Parameter resolve: The `Then` block.
    /// - Parameter reject: The `Catch` block.
    @discardableResult
    public init(dispatchQueue: DispatchQueue? = nil, executor: (_ resolve: @escaping Then, _ reject: @escaping Catch) -> Void) {
        self.dispatchQueue = dispatchQueue
        executor(self.resolve, self.reject)
    }

    /// Initialze a pending Promise.
    public init() {
        self.state = .pending
    }

    /// Intialize a resolved Promise
    /// - Parameter value: The Promise's resolved value.
    public init(_ value: Value) {
        self.state = .resolved(value)
    }

    /// Intialize a resolved Promise.
    /// - Parameter resolvedValue: The function returning the Promise's resolved value.
    @discardableResult
    public init(_ resolvedValue: @escaping () -> Value) {
        self.state = .resolved(resolvedValue())
    }

    /// Intialize a rejected Promise.
    /// - Parameter error: The Promise's error.
    public init(_ error: ErrorType) {
        self.state = .rejected(error)
    }

    /// Intialize a rejected Promise.
    /// - Parameter errorValue: The function returning the Promise's error.
    @discardableResult
    public init(_ errorValue: @escaping () -> ErrorType) {
        self.state = .rejected(errorValue())
    }

    /// Internal helper function: Handles resolving the Promise.
    /// - Parameter onResolved: The `Then` block.
    /// - Parameter onRejected: The `Catch` block.
    private func internalThen(onResolved: @escaping Then = { _ in }, onRejected: @escaping Catch = { _ in }) {
        self.callback = onResolved
        self.triggerCallbacksIfResolved()
        self.errorCallback = onRejected
        self.triggerErrorCallbacksIfRejected()
    }

    /// Handles resolving the Promise (flatMap).
    /// - Parameter onResolved: Block to execute when resolved.
    public func then<NewValue>(_ onResolved: @escaping (Value) -> BasePromise<NewValue, ErrorType>) -> BasePromise<NewValue, ErrorType> {
        return BasePromise<NewValue, ErrorType> { resolve, reject in
            self.internalThen(onResolved: { (value) in
                onResolved(value).then(resolve).catch(reject)
            })
        }
    }

    /// Handles resolving the Promise (map).
    /// - Parameter onResolved: Block to execute when resolved.
    @discardableResult
    public func then<NewValue>(_ onResolved: @escaping (Value) -> NewValue) -> BasePromise<NewValue, ErrorType> {
        return BasePromise<NewValue, ErrorType> { resolve, reject in
            return self.internalThen(onResolved: { (val) in
                resolve(onResolved(val))
            }, onRejected: { (error) in
                reject(error)
            })
        }
    }

    /// Handles resolving the Promise.
    /// - Parameter onResolved: Block to execute when resolved.
    public func then(_ onResolved: @escaping Then) {
        self.internalThen(onResolved: onResolved)
    }

    /// The error callback for the given Promise.
    /// - Parameter onRejected: The `Catch` block.
    public func `catch`(_ onRejected: @escaping Catch) {
        return self.internalThen(onRejected: onRejected)
    }

    /// The error callback for the given Promise. Returns another Promise.
    /// - Parameter onRejected: The `Catch` block.
    public func `catch`<NewValue>(_ onRejected: @escaping (ErrorType) -> NewValue) -> BasePromise<NewValue, ErrorType> {
        return BasePromise<NewValue, ErrorType> { resolve, reject in
            return self.internalThen(onResolved: { (val) in
                reject(NSError(domain: "", code: 0, userInfo: [:]) as! ErrorType) // The error to be returned and ignored by Always
            }, onRejected: { (error) in
                resolve(onRejected(error))
            })
        }
    }

    /// Called always.
    /// - Parameter onAlways: Block to execute always.
    public func always(_ onAlways: @escaping Always) {
        return self.internalThen(onResolved: { _ in
            onAlways()
        }, onRejected: { _ in
            onAlways()
        })
    }

    private func reject(error: ErrorType) {
        self.updateState(to: .rejected(error))
        self.triggerErrorCallbacksIfRejected()
    }

    private func resolve(value: Value) {
        self.updateState(to: .resolved(value))
        self.triggerCallbacksIfResolved()
    }

    private func updateState(to newState: State<Value, ErrorType>) {
        guard case .pending = self.state else { return }
        self.state = newState
    }

    private func triggerCallbacksIfResolved() {
        guard case let .resolved(value) = self.state else { return }
        guard let callback = self.callback else { return }
        if let dispatchQueue = self.dispatchQueue {
            dispatchQueue.async {
                callback(value)
            }
        } else {
            callback(value)
        }
    }

    private func triggerErrorCallbacksIfRejected() {
        guard case let .rejected(error) = self.state else { return }
        guard let errorCallback = self.errorCallback else { return }
        if let dispatchQueue = self.dispatchQueue {
            dispatchQueue.async {
                errorCallback(error)
            }
        } else {
            errorCallback(error)
        }
    }
}
