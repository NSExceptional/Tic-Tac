//
//  ComposeViewController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 8/17/22.
//

import UIKit
import YakKit

class ComposeViewController: UIViewController {
    typealias SubmissionHandler = (_ text: String, _ completionHandler: @escaping (Error?) -> Void) -> Void
    
    enum Mode {
        case composeYak, composeComment
        
        var title: String {
            switch self {
                case .composeYak:
                    return "New Yak"
                case .composeComment:
                    return "New Comment"
            }
        }
    }
    
    private lazy var textArea: UITextView = .init()
    private var participants: [YYUser] = []
    private var mode: Mode = .composeYak
    private let characterLimit = 200
    
    private var submissionHandler: SubmissionHandler = { _, _ in }
    private var accessoryView: ComposeInputAccessoryView? = nil
    private lazy var characterCountLabel = UILabel(textStyle: .body).color(.systemPurple)
    
    convenience init(participants: [YYUser]? = nil, onSubmit: @escaping SubmissionHandler) {
        self.init()
        self.submissionHandler = onSubmit
        
        if let users = participants {
            self.participants = users
            self.mode = .composeComment
        }
    }
    
    override func loadView() {
        super.loadView()
        
        // Add text view
        self.view.addSubview(self.textArea)
        self.textArea.frame = self.view.bounds
        self.textArea.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.textArea.textContainerInset = .init(vertical: 10, horizontal: 6)
        self.textArea.font = .systemFont(ofSize: 24)
        
        self.view.backgroundColor = .secondarySystemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.mode.title
        
        // Button to dismiss
        self.navigationItem.rightBarButtonItem = .button(symbol: "xmark") {
            self.dismiss()
        }
        
        // Input accessory view with @ suggestions and submit button
        self.accessoryView = .init(self.participants) { [unowned self] in
            self.dismiss(submit: true)
        }
        
        self.textArea.inputAccessoryView = self.accessoryView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textArea.becomeFirstResponder()
    }
    
    private func dismiss(submit: Bool = false) {
        self.textArea.resignFirstResponder()
        self.navigationController?.view.isUserInteractionEnabled = false
        
        if submit {
            self.navigationController?.dismissSelf()
        }
        else {
            self.navigationController?.dismissSelf()
        }
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.accessoryView?.submitEnabled = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newString.length <= self.characterLimit
    }
}

class ComposeInputAccessoryView: UIToolbar {
    private var submitButton: UIBarButtonItem!
    private var participants: [YYUser] = []
    
    var submitEnabled: Bool {
        get { submitButton.isEnabled }
        set { submitButton.isEnabled = newValue }
    }
    
    convenience init(_ participants: [YYUser] = [], postAction: @escaping () -> Void) {
        self.init()
        self.sizeToFit()
        self.participants = participants
        self.submitButton = .button(text: "Submit", action: postAction)
        
        self.items = [.flexibleSpace(), self.submitButton]
    }
}
