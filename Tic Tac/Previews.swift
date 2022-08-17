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

@available(iOS 13.0, *)
struct TicTacPreviews: PreviewProvider {
    
    static let target = TabBarController()
    
    static var platform: PreviewPlatform? {
        return SwiftUI.PreviewPlatform.iOS
    }
    
    static var previews: some SwiftUI.View {
        UIKitPreview(self.target)
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
    }
    
    init(_ view: UIView, size: CGSize? = nil) {
        self.size = size
        self.view = view
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
