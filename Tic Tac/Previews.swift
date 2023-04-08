//
//  Previews.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/17/22.
//

#if DEBUG
#if targetEnvironment(simulator)

import UIKit
import SwiftUI
import YakKit

extension CGRect {
    static let medium: CGRect = .init(x: 0, y: 0, width: 375, height: 375)
}

@available(iOS 13.0, *)
struct TicTacPreviews: PreviewProvider {
    typealias TargetType = UserEmojiPickerView
//    typealias TargetType = UserEmojiView
//    static let yak = PreviewData.yak()
//    static let context = PreviewData.context(origin: .userProfile)
    
    static var target = TargetType(.zero)
    
    static func configure() {
        target.backgroundColor = .systemRed
//        target.set(emoji: yak.emoji, colors: (yak.colorHex!, yak.colorSecondaryHex!))
//        target.configure(with: yak, context: context)
    }
    
    static var configuredTarget: TargetType {
        self.configure()
        return self.target
    }
    
    static var previews: some SwiftUI.View {
        UIKitPreview(self.configuredTarget, size: .square(200))
//            .ignoresSafeArea()
    }
}

struct UIKitPreview: View, UIViewRepresentable {
    typealias UIViewType = UIView
    
    var size: CGSize?
    let view: UIView
    
    init(_ controller: UIViewController) {
        self.size = UIScreen.main.bounds.size
        self.size?.height += 50
        self.view = controller.view
        controller.overrideUserInterfaceStyle = .dark
    }
    
    init(_ view: UIView, size: CGSize) {
        self.size = size
        self.view = PreviewBox(child: view, size: size)
        self.view.overrideUserInterfaceStyle = .dark
    }
    
    func makeUIView(context: Context) -> UIView {
        if let size = self.size {
            self.view.frame.size = size
        }
        else {
            self.view.sizeToFit()
        }
        
        return self.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

#endif
#endif
