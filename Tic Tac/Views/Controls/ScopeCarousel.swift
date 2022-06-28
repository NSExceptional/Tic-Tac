//
//  ScopeCarousel.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/13/22.
//

import UIKit

@objcMembers
class ScopeCarousel: UIControl, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private enum Constants {
        static let itemSpacing: CGFloat = 0
        static let cellReuseID: String = "ScopeCarousel.cellReuseID"
    }
    
    var items: [String] = [] {
        didSet {
            // Refresh list, select first item initially
            self.collectionView.reloadData()
            self.selectedIndex = 0
        }
    }

    var selectedIndex: Int = 0 {
        didSet {
            assert(self.selectedIndex < self.items.count)

            let path = IndexPath(item: self.selectedIndex, section: 0)
            self.collectionView.selectItem(
                at: path,
                animated: true,
                scrollPosition: .centeredHorizontally
            )
            self.collectionView(self.collectionView, didSelectItemAt: path)
        }
    }
    
    var selectedIndexChangedAction: ((_ idx: Int) -> Void)?
    private var sizingCell: CarouselCell = .init(title: "NSObject")
    private var dynamicTypeObserver: Any = 0
    private var dynamicTypeHandlers: [(ScopeCarousel) -> Void] = []
    private var constraintsInstalled: Bool = false
    private lazy var collectionView: UICollectionView = {
        let itemSize = UICollectionViewFlowLayout.automaticSize
        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = .zero
            layout.minimumLineSpacing = Constants.itemSpacing
            layout.itemSize = itemSize
            layout.estimatedItemSize = itemSize
            return layout
        }()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(CarouselCell.self, forCellWithReuseIdentifier: Constants.cellReuseID)

        self.addSubview(cv)
        return cv
    }()

    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.autoresizingMask = .flexibleWidth
        self.translatesAutoresizingMaskIntoConstraints = true

        // Dynamic type
        self.dynamicTypeObserver = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: nil,
            using: { [weak self] note in
                guard let self = self else { return }
                
                self.collectionView.setNeedsLayout()
                self.setNeedsUpdateConstraints()

                // Notify observers
                self.dynamicTypeHandlers.forEach { block in
                    block(self)
                }
            }
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(dynamicTypeObserver)
    }

    // MARK: - Overrides

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let width = 1.0 / UIScreen.main.scale

        // Draw hairline
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.systemGray3.cgColor)
            context.setLineWidth(width)
            context.move(to: CGPoint(x: 0, y: rect.size.height - width))
            context.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - width))
            context.strokePath()
        }
    }

    override class var requiresConstraintBasedLayout: Bool { true }

    override func updateConstraints() {
        if !constraintsInstalled {
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.pinEdgesToSuperview()

            constraintsInstalled = true
        }

        super.updateConstraints()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.sizingCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        )
    }

    func registerBlock(forDynamicTypeChanges handler: @escaping (ScopeCarousel) -> Void) {
        self.dynamicTypeHandlers.append(handler)
    }

    // MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //    if (@available(iOS 10.0, *)) {
        //        return UICollectionViewFlowLayoutAutomaticSize;
        //    }

        self.sizingCell.title = self.items[indexPath.item]
        return self.sizingCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarouselCell = collectionView.dequeueCell(for: indexPath)
        cell.title = self.items[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.item // In case self.selectedIndex didn't trigger this call

        if let selectedIndexChangedAction = self.selectedIndexChangedAction {
            selectedIndexChangedAction(indexPath.row)
        }

        // TODO: dynamically choose a scroll position. Very wide items should
        // get "Left" while smaller items should not scroll at all, unless
        // they are only partially on the screen, in which case they
        // should get "HorizontallyCentered" to bring them onto the screen.
        // For now, everything goes to the left, as this has a similar effect.
        self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        self.sendActions(for: .valueChanged)
    }
}
