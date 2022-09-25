//
//  UIKit+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/14/22.
//

import UIKit
import TBAlertController

extension CGRect {
    static func square(_ size: CGFloat) -> Self {
        return .init(origin: .zero, size: .square(size))
    }
}

extension CGSize {
    static func square(_ size: CGFloat) -> Self {
        return .init(width: size, height: size)
    }
}

extension UIEdgeInsets {
    init(all inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    init(vertical v: CGFloat, horizontal h: CGFloat) {
        self.init(top: v, left: h, bottom: v, right: h)
    }
    
    func vertical(_ v: CGFloat) -> UIEdgeInsets {
        return .init(top: v, left: self.left, bottom: v, right: self.right)
    }
    
    func horizontal(_ h: CGFloat) -> UIEdgeInsets {
        return .init(top: self.top, left: h, bottom: self.bottom, right: h)
    }
    
    func vertical(offset: CGFloat) -> UIEdgeInsets {
        return .init(top: self.top + offset, left: self.left, bottom: self.bottom + offset, right: self.right)
    }
    
    func horizontal(offset: CGFloat) -> UIEdgeInsets {
        return .init(top: self.top, left: self.left + offset, bottom: self.bottom, right: self.right + offset)
    }
}

extension UIImage {
    static func symbol(_ name: String, size: SymbolScale = .default, color: UIColor? = nil) -> UIImage {
        var icon: UIImage
        
        if size == .default {
            icon = UIImage(systemName: name)!
        }
        else {
            let config = SymbolConfiguration(scale: size)
            icon = UIImage(systemName: name, withConfiguration: config)!
        }
        
        if let color = color {
            icon = icon.withTintColor(color, renderingMode: .alwaysTemplate)
        }
        
        return icon
    }
}

extension UIMenu {
    static func inline(_ title: String = "", image: UIImage? = nil,
                       options: Options = [.displayInline], items: [UIMenuElement]) -> UIMenu {
        return UIMenu(title: title, image: image, identifier: nil, options: options, children: items)
    }
    
    var collapsed: UIMenu {
        return UIMenu.inline(items: [
            UIMenu(
                title: self.title,
                image: self.image,
                identifier: self.identifier,
                options: [],
                children: self.children
            )
        ])
    }
}

extension UIAction {
    convenience init(copyText value: String, title: String, disabled: Bool = false) {
        self.init(
            title: title,
            image: UIImage(systemName: "doc.on.doc"),
            identifier: nil,
            handler: { _ in
                UIPasteboard.general.string = value
            }
        )
        
        if disabled {
            self.attributes = .disabled
        }
    }
    
    convenience init(title: String = "", image: UIImage?, handler: @escaping UIActionHandler) {
        self.init(title: title, image: image, attributes: [], handler: handler)
    }
}

extension UIBarButtonItem {
    static var fixedSpace: UIBarButtonItem { .fixedSpace(60) }
    
    @available(iOS 14.0, *)
    class func button(symbol: String, action: @escaping () -> Void) -> UIBarButtonItem {
        let image = UIImage(systemName: symbol)
        let handler = { (_: UIAction) in action() }
        return UIBarButtonItem(title: nil, image: image, primaryAction: .init(handler: handler))
    }
    
    @available(iOS 14.0, *)
    class func button(text: String, action: @escaping () -> Void) -> UIBarButtonItem {
        let handler = { (_: UIAction) in action() }
        let item = UIBarButtonItem(title: text, style: .done, target: nil, action: nil)
        item.primaryAction = .init(handler: handler)
        item.title = text
        return item
    }
}

extension UIRefreshControl {
    func revealAndBeginRefreshing() {
        if let scrollView = superview as? UITableView {
            let offset: CGFloat = scrollView.contentOffset.y - frame.height
            scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        
        self.beginRefreshing()
    }

}
extension UIApplication {
    static var keyWindow: UIWindow {
        return self.shared.delegate!.window!!
    }
}

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }

    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }

    private var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }

    private var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

extension UITableView {
    func registerCells(_ types: [UITableViewCell.Type]) {
        for cellClass in types {
            self.register(cell: cellClass)
        }
    }
    
    func register(cell: UITableViewCell.Type) {
        self.register(cell, forCellReuseIdentifier: NSStringFromClass(cell))
    }
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = NSStringFromClass(T.self)
        return self.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as! T
    }
    
    func scroll(to row: Int, in section: Int = 0, at position: ScrollPosition = .middle, animated: Bool = true) {
        let ip = IndexPath(row: row, section: section)
        self.scrollToRow(at: ip, at: position, animated: animated)
    }
}

extension UIView {
    func pinEdges(to view: UIView, insets i: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: i.top),
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: i.left),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -i.bottom),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -i.right),
        ])
    }
    
    func pinEdges(to view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func pinEdgesToSuperview(insets: UIEdgeInsets? = nil) {
        guard let sv = self.superview else { return }
        if let insets = insets {
            self.pinEdges(to: sv, insets: insets)
        } else {
            self.pinEdges(to: sv)
        }
    }
    
    @discardableResult
    func hugging(_ priority: UILayoutPriority, axis: NSLayoutConstraint.Axis) -> Self {
        self.setContentHuggingPriority(priority, for: axis)
        return self
    }
    
    @discardableResult
    func expansion(_ priority: UILayoutPriority, axis: NSLayoutConstraint.Axis) -> Self {
        self.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
}

extension UICollectionView {
    func register(cell: UICollectionViewCell.Type) {
        self.register(cell, forCellWithReuseIdentifier: NSStringFromClass(cell))
    }
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(T.self),
            for: indexPath
        ) as! T
    }
}

extension UIColor {
    private typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    
    private var rgb: RGBA {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    convenience init(hex string: String) {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: string)
        
        _ = scanner.scanString("#")
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let rb = Int(color >> 16) & mask
        let gb = Int(color >> 8) & mask
        let bb = Int(color) & mask

        let r = CGFloat(rb) / 255.0
        let g = CGFloat(gb) / 255.0
        let b = CGFloat(bb) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    static var mintColor: UIColor {
//        #if compiler(>=5.5)
//        if #available(iOS 15, *) {
//            return .systemMintColor
//        }
//        #endif
        
        return .init(red: 0, green: 150, blue: 142, alpha: 1)
//        return .init { traits -> UIColor in
//            switch traits.userInterfaceStyle {
//                case .dark:
//                    return .init(red: 102, green: 212, blue: 107, alpha: 1)
//                default:
//            }
//        }
    }
    
    convenience init(interpolate percent: CGFloat, from start: UIColor, to end: UIColor) {
        let r = start.rgb
        let l = end.rgb

        let color: RGBA = (
            (l.r - r.r) * percent + r.r,
            (l.g - r.g) * percent + r.g,
            (l.b - r.b) * percent + r.b,
            (l.a - r.a) * percent + r.a
        )
        
        self.init(red: color.r, green: color.g , blue: color.b, alpha: color.a)
    }
}

extension UILabel {
    func multiline() -> UILabel {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        self.setContentHuggingPriority(.required, for: .vertical)
        return self
    }
    
    func color(_ textColor: UIColor) -> UILabel {
        self.textColor = textColor
        return self
    }
    
    func align(_ alignment: NSTextAlignment) -> UILabel {
        self.textAlignment = alignment
        return self
    }
    
    convenience init(textStyle style: UIFont.TextStyle) {
        self.init()
        self.font = .preferredFont(forTextStyle: style)
    }
    
    convenience init(font: UIFont) {
        self.init()
        self.font = font
    }
}

extension UIStackView {
    func alignment(_ align: Alignment) -> UIStackView {
        self.alignment = align
        return self
    }
    
    func axis(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        self.axis = axis
        return self
    }
    
    func distribution(_ dist: Distribution) -> UIStackView {
        self.distribution = dist
        return self
    }
    
    func spacing(_ spacing: CGFloat) -> UIStackView {
        self.spacing = spacing
        return self
    }
    
    func customSpacing(_ spacing: CGFloat, after view: UIView) -> UIStackView {
        self.setCustomSpacing(spacing, after: view)
        return self
    }
}

extension UIViewController {
    func presentError(_ error: Error, title: String) {
        TBAlert.make({ make in
            make.title(title)
            make.message(error.localizedDescription)
            make.button("Dismiss")
        }, showFrom: self)
    }
    
    func dismissSelf() {
        self.presentingViewController?.dismiss(animated: true)
    }
}

extension UIFont {
    @objc private class var defaultSizes: [TextStyle: CGFloat] { __defaultSizes }
    private static var __defaultSizes: [TextStyle: CGFloat] = [
        .largeTitle: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize,
        .title1: UIFont.preferredFont(forTextStyle: .title1).pointSize,
        .title2: UIFont.preferredFont(forTextStyle: .title2).pointSize,
        .title3: UIFont.preferredFont(forTextStyle: .title3).pointSize,
        .headline: UIFont.preferredFont(forTextStyle: .headline).pointSize,
        .subheadline: UIFont.preferredFont(forTextStyle: .subheadline).pointSize,
        .body: UIFont.preferredFont(forTextStyle: .body).pointSize,
        .callout: UIFont.preferredFont(forTextStyle: .callout).pointSize,
        .footnote: UIFont.preferredFont(forTextStyle: .footnote).pointSize,
        .caption1: UIFont.preferredFont(forTextStyle: .caption1).pointSize,
        .caption2: UIFont.preferredFont(forTextStyle: .caption2).pointSize,
    ]
    
    @objc private class var defaultSize: CGFloat { UIFont.defaultSizes[.body]! }
    
    class func monospace(_ style: UIFont.TextStyle? = nil, weight: UIFont.Weight = .regular) -> UIFont {
        if let style = style {
            return .monospacedSystemFont(ofSize: UIFont.defaultSizes[style]!, weight: weight)
        }
        
        return .monospacedSystemFont(ofSize: UIFont.defaultSize, weight: weight)
    }
    
    class func italic(_ style: UIFont.TextStyle? = nil) -> UIFont {
        if let style = style {
            return .italicSystemFont(ofSize: UIFont.defaultSizes[style]!)
        }
        
        return .italicSystemFont(ofSize: UIFont.defaultSize)
    }
    
    static let headline: UIFont = .preferredFont(forTextStyle: .headline)
    static let footnote: UIFont = .preferredFont(forTextStyle: .footnote)
    static let isOP: UIFont = UIFont.systemFont(ofSize: UIFont.footnote.pointSize, weight: .medium)
    
    func styled(as style: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self)
    }
}

extension UIContextualAction {
    convenience init(handler: @escaping UIContextualAction.Handler) {
        self.init(style: .normal, title: nil, handler: handler)
    }
    
    func title(_ title: String) -> UIContextualAction {
        self.title = title
        return self
    }
    
    func image(_ image: UIImage) -> UIContextualAction {
        self.image = image
        return self
    }
    
    func symbol(_ symbol: String) -> UIContextualAction {
        return self.image(UIImage(systemName: symbol)!)
    }
    
    func color(_ color: UIColor) -> UIContextualAction {
        self.backgroundColor = color
        return self
    }
}
