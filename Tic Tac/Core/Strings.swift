//
//  Strings.swift
//  Receiptie
//
//  Created by Tanner Bennett on 3/30/22.
//  Copyright © 2022 Tanner Bennett. All rights reserved.
//

import Foundation

infix operator ~~ : AdditionPrecedence
func ~~(string: String, startOffset: Int) -> String.Index {
    return string.index(string.startIndex, offsetBy: startOffset)
}

typealias StringPart = StringBuilder.Component

/// Simple plural/singular localization
extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ n: Int, _ singular: String, plural: String? = nil) {
        self.appendInterpolation(n)
        self.appendLiteral(" ")
        
        if n == 1 {
            self.appendLiteral(singular)
        } else if let plural = plural {
            self.appendLiteral(plural)
        } else {
            self.appendLiteral(singular + "s")
        }
    }
}

extension Array where Element == StringBuilder.Component {
    var string: String {
        return StringBuilder(components: self).string
    }
}

struct StringBuilder {
    enum Component {
        case subcomponent([Component])
        case text(String?)
        case count(Int, String)
        case date(Date?, DateFormatter.Format)
        case comma, dot, bar
    }
    
    fileprivate class Node {
        var value: Component
        weak var parent: Node?
        var next: Node? {
            didSet { next?.parent = self }
        }
        
        /// Does not prune before building
        func buildString() -> String {
            return self.map(\.string).joined()
        }
        
        /// Only prunes self and children; does not modify parent
        func prune() -> Node? {
            // Case: last node
            var head: Node! = self
            
            // Prune children
            head.next = head.next?.prune()
            
            // Maybe prune self
            while head?.skip ?? false {
                // If head is the last node, nil is returned
                head.next?.parent = head.parent
                head = head.next
            }
            
            // Case: head was last and pruned self
            guard head != nil else {
                return nil
            }
            
            // Remove successive separators
            while let next = head.next, head.value.isSeparator && next.value.isSeparator {
                head.next = next.next
            }
            
            return head
        }
        
        init(value: Component) {
            self.value = value
            self.next = nil
        }
    }
    
    private func buildTree() -> Node? {
        let nodes = self.components.map { Node(value: $0) }
        
        for i in 1..<nodes.count {
            // Assign "parent" nodes
            nodes[i].parent = nodes[i-1]
            // Assign "next" nodes
            nodes[i-1].next = nodes[i]
        }
        
        return nodes.first!.prune()
    }

    var components: [Component] = []
    var string: String {
        return self.buildTree()?.buildString() ?? ""
    }
}

fileprivate extension StringBuilder.Component {
    var isSeparator: Bool {
        switch self {
            case .comma, .dot, .bar:
                return true
            default:
                return false
        }
    }

    var value: String {
        switch self {
            case .subcomponent(let list):
                return StringBuilder(components: list).string
            case .text(let s):
                return s ?? ""
            case .count(let n, let name):
                return "\(n, name)"
            case .date(let d, let f):
                if let d = d {
                    return DateFormatter.string(from: d, format: f)
                }
                return "undated"
                
            case .comma:
                return ", "
            case .dot:
                return " • "
            case .bar:
                return " | "
        }
    }
    
    var empty: Bool {
        switch self {
            case .subcomponent(let list):
                return list.isEmpty
            case .text(let s):
                return s == nil || s!.isEmpty
            case .count(_, _):
                return false
            case .date(let d, _):
                return d == nil
            case .comma, .dot, .bar:
                return false
        }
    }
}

fileprivate extension StringBuilder.Node {
    var skip: Bool {
        if self.value.isSeparator {
            // Skip separators if no parent or no child
            if self.parent == nil || self.next == nil {
                return true
            }
        }
        
        return self.value.empty
    }
    
    var string: String {
        if self.value.isSeparator {
            return self.value.value
        } else {
            if let next = next {
                if next.value.isSeparator {
                    // No trailing whitespace before separator
                    return self.value.value
                }
                
                // Trailing whitespace; no separator, but not last
                return self.value.value + " "
            }
            
            // Last node; no trailing whitespace
            return self.value.value
        }
    }
    
    func map<T>(_ transform: (StringBuilder.Node) throws -> T) rethrows -> [T] {
        var values: [T] = []
        var cursor: StringBuilder.Node? = self
        
        while cursor != nil {
            values.append(try transform(cursor!))
            cursor = cursor?.next
        }
        
        return values
    }
}

extension String {
    var length: Int {
        return self.lengthOfBytes(using: .utf8)
    }
    
    subscript(range: Range<Index>) -> String {
        get { return String(self[range]) }
        set { self.replaceSubrange(range, with: newValue) }
    }
    
    func getIndex(_ v: Int) -> Index {
        return self.index(startIndex, offsetBy: v)
    }
    
    func indexRange(_ r: CountableRange<Int>) -> Range<Index> {
        let start = getIndex(r.lowerBound)
        let end = index(start, offsetBy:  r.count)
        return start..<end
    }
    
    func indexRange(_ r: PartialRangeFrom<Int>) -> PartialRangeFrom<Index> {
        let start = getIndex(r.lowerBound)
        return start...
    }
    
    func indexRange(_ r: PartialRangeThrough<Int>) -> PartialRangeThrough<Index> {
        let end = index(self.startIndex, offsetBy:  r.upperBound)
        return ...end
    }
    
    func indexRange(_ r: PartialRangeUpTo<Int>) -> PartialRangeUpTo<Index> {
        let end = index(self.startIndex, offsetBy:  r.upperBound)
        return ..<end
    }
    
    subscript(index: Int) -> Character {
        get { return self[getIndex(index)] }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get { return self[indexRange(range)] }
    }
    
    subscript(range: PartialRangeFrom<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    subscript(range: PartialRangeThrough<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    subscript(range: PartialRangeUpTo<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    subscript(range: NSRange) -> String {
        get { return self[CountableRange<Int>(range)!] }
    }
}
