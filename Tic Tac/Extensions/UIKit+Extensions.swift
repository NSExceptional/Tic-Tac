//
//  UIKit+Extensions.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/14/22.
//

import UIKit

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
    
    convenience init(title: String, image: UIImage?, handler: @escaping UIActionHandler) {
        self.init(title: title, image: image, attributes: [], handler: handler)
    }
}

extension UIBarButtonItem {
    static var fixedSpace: UIBarButtonItem { .fixedSpace(60) }
}

extension UIApplication {
    static var keyWindow: UIWindow {
        return self.shared.delegate!.window!!
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
    
    convenience init(textStyle style: UIFont.TextStyle) {
        self.init()
        self.font = .preferredFont(forTextStyle: style)
    }
}
