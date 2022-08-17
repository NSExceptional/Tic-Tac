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
    indirect enum Component {
        case subcomponent([Component])
        case text(String?)
        case count(Int, String? = nil, exclude: Bool = false)
        case date(Date?, DateFormatter.Format)
        case separator(Separator)
        
        case symbol(String?, UIColor? = nil, exclude: Bool = false)
        case attachment(NSTextAttachment, exclude: Bool = false)
        case attrText(String?, [NSAttributedString.Key : Any], exclude: Bool = false)
        case leadingSpace(Component)
        case colored(Component, UIColor?, exclude: Bool = false)
        
        /// Newline separator
        static let nwln: Component = .separator(.newline)
        static let comma: Component = .separator(.comma)
        static let dot: Component = .separator(.dot)
        static let bar: Component = .separator(.bar)
        
        enum Separator: String {
            case comma = ", "
            case dot = " • "
            case bar = " | "
            case newline = "\n"
        }
    }
    
    fileprivate class Node {
        var value: Component
        weak var parent: Node?
        var next: Node? {
            didSet { next?.parent = self }
        }
        
        /// Does not prune before building
        func buildString(_ spaceWidth: Int) -> String {
            var parts = self.map(\.string)
            if spaceWidth > 1 {
                // Take the last space and multiply it
                parts = parts.map { $0.replacing(" ", with: " " * spaceWidth, range: $0.lastCharacterRange) }
            }
            
            return parts.joined()
        }
        
        /// Does not prune before building
        func buildAttributedString(_ spaceWidth: Int) -> NSAttributedString {
            let parts = self.map(\.attributedString)
            if spaceWidth > 1 {
                // Take the last space and multiply it
                parts.forEach { $0.replaceOccurrences(of: " ", with:  " " * spaceWidth, range: $0.lastCharacterRange) }
            }
            
            return parts.joined()
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
        
        init(value: Component, next: Node? = nil) {
            self.value = value
            self.next = next
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

    /// Increase the size of a space within the string.
    var spaceWidth = 1
    var components: [Component] = []
    var string: String {
        return self.buildTree()?.buildString(self.spaceWidth) ?? ""
    }
    
    var attributedString: NSAttributedString {
        return self.buildTree()?.buildAttributedString(self.spaceWidth) ?? .init(string: "")
    }
}

extension StringBuilder: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = StringBuilder.Component
    
    init(arrayLiteral elements: Component...) {
        self.init(components: elements)
    }
}

fileprivate extension StringBuilder.Component {
    var isSeparator: Bool {
        switch self {
            case .separator(_):
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
            case .count(let n, let name, _):
                if let name = name {
                    return "\(n, name)"
                }
                return "\(n)"
            case .date(let d, let f):
                if let d = d {
                    return DateFormatter.string(from: d, format: f)
                }
                return "undated"
                
            case .symbol(let name, _, _):
                return name ?? ""
            case .attachment(let attachment, _):
                return attachment.description
            case .attrText(let str, _, _):
                return str ?? ""
                
            case .leadingSpace(let c):
                return " " + c.value
            case .colored(let c, _, _):
                return c.value
                
            case .separator(let s):
                return s.rawValue
        }
    }
    
    var attributedValue: NSMutableAttributedString {
        switch self {
            case .symbol(let name, let color, _):
                // Safe to unwrap name here because invoking this method
                // on empty components is against the rules
                var image = UIImage(systemName: name!)!
                if let color = color {
                    image = image.withTintColor(color)
                }
                
                return .init(attachment: .init(image: image))
                
            case .attachment(let attachment, _):
                return .init(attachment: attachment)
            case .attrText(let str, let attrs, _):
                return .init(string: str ?? "", attributes: attrs)
                
            case .leadingSpace(let c):
                return " " + c.attributedValue
            case .colored(let c, let color, _):
                guard let color = color else {
                    return c.attributedValue
                }
                
                return c.attributedValue.withColor(color)
                
            default:
                return .init(string: self.value)
        }
    }
    
    var empty: Bool {
        switch self {
            case .subcomponent(let list):
                return list.isEmpty
            case .text(let s):
                return s == nil || s!.isEmpty
            case .count(_, _, let exclude):
                return exclude
            case .date(let d, _):
                return d == nil
            case .separator(_):
                return false
                
            case .leadingSpace(let c):
                return c.value.isEmpty
            case .colored(let c, _, let exclude):
                return c.value.isEmpty || exclude
                
            case .symbol(let name, _, let exclude):
                return name == nil || exclude
            case .attachment(_, let exclude):
                return exclude
            case .attrText(let s, _, let exclude):
                return s == nil || s!.isEmpty || exclude
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
    
    var attributedString: NSMutableAttributedString {
        switch self.value {
            case .symbol(_, _, _):
                // No trailing space after symbols
                return self.value.attributedValue
            
            case .colored(let c, let color, _):
                // This is just easier... sheesh. Don't forget to pass in `next`
                return StringBuilder.Node(value: c, next: self.next).attributedString.withColor(color)
                
            case .attachment(_, _), .attrText(_, _, _), .leadingSpace(_):
                if let next = next {
                    if next.value.isSeparator {
                        // No trailing whitespace before separator
                        return self.value.attributedValue
                    }
                    
                    // Trailing whitespace; no separator, but not last
                    return self.value.attributedValue + " "
                }
                
                // Last node; no trailing whitespace
                return self.value.attributedValue
                
            default:
                return .init(string: self.string)
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

extension Array where Element == NSMutableAttributedString {
    func joined() -> NSMutableAttributedString {
        let mstring = NSMutableAttributedString()
        for s in self {
            mstring.append(s)
        }
        
        return mstring
    }
}

extension String {
    var length: Int {
        return self.lengthOfBytes(using: .utf8)
    }
    
    fileprivate var fullRange: Range<Index> {
        return self.startIndex..<self.endIndex
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
    
    /// Range<Int>
    subscript(range: CountableRange<Int>) -> String {
        get { return self[indexRange(range)] }
    }
    
    /// N...
    subscript(range: PartialRangeFrom<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    /// ...N
    subscript(range: PartialRangeThrough<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    /// ..<N
    subscript(range: PartialRangeUpTo<Int>) -> String {
        get { return String(self[indexRange(range)]) }
    }
    
    subscript(range: NSRange) -> String {
        get { return self[CountableRange<Int>(range)!] }
    }
}

func * (rhs: String, lhs: Int) -> String {
    return .init(repeating: rhs, count: lhs)
}

func + (rhs: NSMutableAttributedString, lhs: String) -> NSMutableAttributedString {
    rhs.append(.init(string: lhs))
    return rhs
}

func + (rhs: String, lhs: NSMutableAttributedString) -> NSMutableAttributedString {
    let mstring = NSMutableAttributedString(string: rhs)
    mstring.append(lhs)
    return mstring
}

extension String {
    var lastCharacterRange: Range<Index> {
        return self.index(before: self.endIndex)..<self.endIndex
    }
    
    func replacing(_ string: String, with replacement: String,
                   options: String.CompareOptions = [], range r: Range<Index>? = nil) -> String {
//        let r = searchRange == nil ? nil : self.indexRange(searchRange!)
        return self.replacingOccurrences(of: string, with: string, options:options, range: r)
    }
}

extension NSMutableAttributedString {
    var lastCharacterRange: NSRange {
        return NSMakeRange(self.length-1, 1)
    }
    
    var fullRange: NSRange {
        return NSMakeRange(0, self.length)
    }
    
    func replaceOccurrences(of string: String, with replacement: String,
                            options: NSString.CompareOptions = [], range searchRange: NSRange? = nil) {
        let r = searchRange ?? NSMakeRange(0, self.mutableString.length)
        self.mutableString.replaceOccurrences(of: string, with: replacement, options: [], range: r)
    }
    
    func withColor(_ color: UIColor?) -> NSMutableAttributedString {
        guard let color = color else {
            return self
        }
        
        self.setAttributes([.foregroundColor: color], range: self.fullRange)
        return self
    }
}
