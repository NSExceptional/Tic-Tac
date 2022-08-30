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

@available(iOS 13.0, *)
struct TicTacPreviews: PreviewProvider {
    static let yak = PreviewData.yak()
    static let context = PreviewData.context(origin: .userProfile)
    
    static var target = YakCell()
    
    static func configure() {
        target.configure(with: yak, context: context)
    }
    
    static var configuredTarget: UIView {
        self.configure()
        return self.target
    }
    
    static var previews: some SwiftUI.View {
        UIKitPreview(self.configuredTarget)
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
    
    init(_ view: UIView, size: CGSize? = nil) {
        self.size = size
        self.view = view
        self.view.overrideUserInterfaceStyle = .dark
        
        if view.backgroundColor == nil {
            view.backgroundColor = .systemBackground
        }
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
