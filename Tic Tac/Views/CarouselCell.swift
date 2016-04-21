//
//  CarouselCell.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

@objcMembers
class CarouselCell: UICollectionViewCell {
    var title: String {
        get {
            self.titleLabel.text ?? ""
        }
        set {
            self.titleLabel.text = newValue
            self.titleLabel.sizeToFit()
            self.setNeedsLayout()
        }
    }
    
    private lazy var titleLabel: UILabel = .init()
    private lazy var selectionIndicatorStripe: UIView = .init()
    private var constraintsInstalled: Bool = false

    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selectionIndicatorStripe = UIView()

        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.selectionIndicatorStripe.backgroundColor = tintColor
        self.titleLabel.adjustsFontForContentSizeCategory = true

        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(selectionIndicatorStripe)
        
        self.installConstraints()
        self.updateAppearance()
    }

    func updateAppearance() {
        self.selectionIndicatorStripe.isHidden = !isSelected

        if self.isSelected {
            self.titleLabel.textColor = tintColor
        } else {
            self.titleLabel.textColor = .secondaryLabel
        }
    }

    // MARK: Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateAppearance()
    }

    func installConstraints() {
        let stripeHeight: CGFloat = 2

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.selectionIndicatorStripe.translatesAutoresizingMaskIntoConstraints = false

        let superview = self.contentView
        self.titleLabel.pinEdgesToSuperview(insets: .init(top: 10, left: 15, bottom: 8 + stripeHeight, right: 15))

        NSLayoutConstraint.activate([
            self.selectionIndicatorStripe.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.selectionIndicatorStripe.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.selectionIndicatorStripe.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self.selectionIndicatorStripe.heightAnchor.constraint(equalToConstant: stripeHeight),
        ])
    }

    override var isSelected: Bool {
        didSet {
            self.updateAppearance()
        }
    }
}
