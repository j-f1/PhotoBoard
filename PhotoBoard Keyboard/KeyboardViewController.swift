//
//  KeyboardViewController.swift
//  PhotoBoard Keyboard
//
//  Created by Jed Fox on 12/6/21.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }

    private var host: UIHostingController<KeyboardView>!

    override func viewDidLoad() {
        super.viewDidLoad()

//        let data = Array(repeating: 0, count: 10).map { _ in CGFloat.random(in: (1/3)...3) }

        host = UIHostingController(rootView: KeyboardView(proxy: textDocumentProxy))
        view.translatesAutoresizingMaskIntoConstraints = false
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        host.willMove(toParent: self)
        addChild(host)
        view.addSubview(host.view)
        view.leadingAnchor.constraint(equalTo: host.view.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: host.view.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: host.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: host.view.bottomAnchor).isActive = true
        host.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        host.view.widthAnchor.constraint(equalTo: view.window!.widthAnchor).isActive = true
    }
    
    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        host.rootView = KeyboardView(proxy: textDocumentProxy, width: size.width)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.white
//        } else {
//            textColor = UIColor.black
//        }
    }

}
