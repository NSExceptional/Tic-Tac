//
//  CardView.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 10/15/22.
//

import UIKit
import SnapKit

fileprivate extension CGFloat {
    static let minimumFlickVelocity: CGFloat = 100
}

fileprivate extension UISheetDetent {
    static let minimized: UISheetDetent = .custom { container, fullHeight, attached in
        // This figure apparently takes the superview's safe area into account automatically
        return 57
    }
}

@objcMembers
class CardView: UIView {
    enum Detent: CGFloat {
        case small = -1
        case medium
    }
    
    // MARK: Properties
    
    private lazy var grabber = UIGrabberMake()
    private lazy var titleLabel: UILabel = .init(font: .boldSystemFont(ofSize: 21))
    private lazy var hairline: UIView = .init(color: .separator)
    private var maxHeightRect: CGRect = .zero
    
    private var detents: [UISheetDetent] = [.large, .medium, .minimized]
    
    // MARK: Public
    
    public var title: String {
        get { return self.titleLabel.text ?? "" }
        set {
            self.titleLabel.text = newValue
            self.titleLabel.sizeToFit()
        }
    }
    
    public func minimize() {
        self.transition(to: self.detents.last!)
    }
    
    public private(set) var contentView: UIView = .init()
    
    public var titleAccessoryView: UIView? {
        willSet {
            // Remove existing accessory view
            if let existing = self.titleAccessoryView {
                existing.removeFromSuperview()
                existing.snp.removeConstraints()
            }
            
            // Add new accessory view with constraints
            if let accessory = newValue {
                accessory.sizeToFit()
                self.addSubview(accessory)
                accessory.snp.makeConstraints { make in
                    make.top.equalTo(self.titleLabel)
                    make.leading.equalTo(self.titleLabel.snp.trailing).offset(15)
                    make.trailing.equalToSuperview().inset(self.titleAreaInsets)
                }
            }
        }
    }
    
    // MARK: Initialization
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("") }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String) {
        super.init(frame: .zero)
        self.setup()
        self.title = title
    }
    
    private func setup() {
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.frame = self.bounds
        
        self.addSubview(blur)
        self.addSubview(self.grabber)
        self.addSubview(self.hairline)
        self.addSubview(self.titleLabel)
        self.addSubview(self.contentView)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.recomputeMaxHeight()
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        self.recomputeMaxHeight()
    }
    
    private func recomputeMaxHeight() {
        guard let parent = self.superview else { return }
        let height = parent.frame.height
        let yOffset = parent.safeAreaInsets.top + 12
        let maxHeight = height - yOffset
        
        var rect = parent.bounds
        rect.size.height = maxHeight
        rect.origin.y = yOffset
        self.maxHeightRect = rect
    }
    
    // MARK: Pan Gesture
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        guard let parent = self.superview else { return }
        
        switch pan.state {
            case .changed:
                self.dragCard(with: pan.translation(in: parent))
                pan.setTranslation(.zero, in: parent)
            case .ended:
                let velocity = pan.velocity(in: parent).y
                let newDetent = self.detent(
                    for: pan.translation(in: parent),
                    velocity: velocity
                )
                self.transition(to: newDetent, with: velocity)
                
            default: break
        }
    }
    
    private func dragCard(with translation: CGPoint) {
        guard let parent = self.superview else { return }
        let yOffset = self.frame.minY + translation.y
        self.setCardYOffset(yOffset, in: parent.frame)
    }
    
    private func detent(for translation: CGPoint, velocity: CGFloat) -> UISheetDetent {
        guard let parent = self.superview else { return .medium }
        /// The computed Y offset of the sheet in the superview, taking velocity into account
        let yOffset = self.frame.minY + translation.y + (velocity / 4)
        
        /// The resolved Y offset of each detent
        let offsets = self.detents
            .map { (detent: $0, offset: self.resolvedYOffset(for: $0, in: parent)) }
        
        // Find the nearest detent by finding the one closest to the current Y offset
        return offsets
            .map { (detent: $0.detent, offset: abs(yOffset - $0.offset)) }
            .min { d1, d2 in
                d1.offset < d2.offset
            }!
            .detent
    }
    
    private func transition(to detent: UISheetDetent, with velocity: CGFloat? = nil) {
        guard let parent = self.superview else { return }
        let newOffset = self.resolvedYOffset(for: detent, in: parent)
        
        self.setCardYOffset(newOffset, in: parent.frame, with: velocity)
    }
    
    private func setCardYOffset(_ newOffset: CGFloat, in parentFrame: CGRect, with velocity: CGFloat? = nil) {
        if let velocity = velocity {
            let newFrame = self.frameFromYOffset(newOffset, in: parentFrame)
            let distance = self.frame.minY - newFrame.minY
            let x = velocity < 0 ? 0.1 : velocity / distance
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: x) {
                self.frame = self.frameFromYOffset(newOffset, in: parentFrame)
            }
        }
        else {
            self.frame = self.frameFromYOffset(newOffset, in: parentFrame)
        }
    }
    
    private func frameFromYOffset(_ offset: CGFloat, in parentFrame: CGRect) -> CGRect {
        var newFrame = self.frame
        newFrame.origin.y = offset
        newFrame.size.height = parentFrame.height - offset
        return newFrame
    }
    
    private func resolvedYOffset(for detent: UISheetDetent, in parent: UIView) -> CGFloat {
        let dy = detent.resolvedOffsetIn(
            container: parent, fullHeight: self.maxHeightRect, bottomAttached: true
        )
        
        if detent.identifier == .medium {
            return dy + 80
        }
        
        return dy
    }
    
    // MARK: AutoLayout
    
    override class var requiresConstraintBasedLayout: Bool { true }
    
    private var titleAreaInsets: UIEdgeInsets { .init(vertical: 16, horizontal: 18) }
    
    override func updateConstraints() {
        self.grabber.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        
        let titleInsets = self.titleAreaInsets
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(titleInsets)
            make.trailing.lessThanOrEqualToSuperview().inset(titleInsets)
        }
        
        self.hairline.snp.makeConstraints { make in
            make.height.equalTo(1 / UIScreen.main.scale)
            make.width.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(titleInsets.bottom)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(hairline.snp.bottom)
        }
        
        super.updateConstraints()
    }
}
