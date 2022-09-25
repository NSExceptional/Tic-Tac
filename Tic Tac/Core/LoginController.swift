//
//  LoginController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/24/22.
//

import UIKit
import TBAlertController
import FirebaseAuth
import YakKit

private class LoginCallbackQueue {
    typealias Callback = () -> Void
    static let main: LoginCallbackQueue = .init()
    
    private init() { }
    
    private var queue: [Callback] = [] {
        didSet { assert(Thread.isMainThread) }
    }
    
    var isEmpty: Bool { queue.isEmpty }
    
    func execute() {
        assert(Thread.isMainThread)
        precondition(!queue.isEmpty)
        
        for cb in self.queue {
            cb()
        }
        
        self.queue = []
    }
    
    func callback(_ cb: Callback?) {
        guard let cb = cb else { return }
        self.queue.append(cb)
    }
}

struct LoginController<T: UIViewController> {
    
    let host: T
    let client: YYClient
    private let onLogin: LoginCallbackQueue = .main
    var loggingIn: Bool { !onLogin.isEmpty }
    
    func requireLogin(reset: Bool = false, _ completion: ((T) -> Void)?) {
        // If we're already logging in, don't duplicate that effort;
        // just enqueue our callbacks and wait
        guard !self.loggingIn else {
            return self.onLogin.callback { completion?(self.host) }
        }
        
        self.onLogin.callback { completion?(self.host) }
        
        if reset {
            self.client.authToken = nil
            Defaults.standard.authToken = nil
        }
        
        // Require location first
        LocationManager.requireLocation { granted in
            if granted {
                self.tryLocateAuthToken { success in
                    if success {
                        self.didSignIn()
                    } else {
                        self.presentLoginForm()
                    }
                }
            } else {
                // Recursively require location until granted
                LocationManager.presentLocationPermissionWarning(from: self.host) {
                    self.requireLogin(completion)
                }
            }
        }
    }
    
    private func tryLocateAuthToken(completion: @escaping (Bool) -> Void) {
        guard !self.client.isLoggedIn else {
            return completion(true)
        }
        
        self.client.loadCurrentUser { error in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func presentLoginForm() {
        TBAlert.make({ make in
            make.title("How Do You Want to Sign In?");
            make.button("Phone Number").handler { _ in
                self.promptForPhoneNumber()
            }.preferred()
            make.button("Auth Token").handler { _ in
                self.promptForAuthToken()
            }
            
        }, showFrom: self.host)
    }
    
    private func promptForAuthToken() {
        TBAlert.make({ make in
            make.title("Sign In with Auth Token")
            make.message("Copy your auth token to the clipboard to sign in.\n\n")
            if (UIPasteboard.general.string?.count ?? 0) < 700 {
                make.message("When you're ready, press 'Continue'")
            } else {
                make.message("It looks like you have it copied! If you're ready, press 'Continue'")
            }

            make.button("Cancel").cancelStyle()
            make.button("Continue").handler { _ in
                let token = UIPasteboard.general.string ?? ""
                if token.count < 700 {
                    self.promptForAuthToken()
                } else {
                    self.client.authToken = UIPasteboard.general.string
                    Defaults.standard.authToken = self.client.authToken
                    self.didSignIn()
                }
            }
        }, showFrom: self.host)
    }
    
    private func promptForPhoneNumber() {
        TBAlert.make({ make in
            make.title("Sign In")
            make.message("Enter your phone number below to get started.")
            make.configuredTextField { textField in
                textField.placeholder = "Phone Number"
                textField.keyboardType = .phonePad
                textField.textContentType = .telephoneNumber
                textField.returnKeyType = .go
            }
            make.button("Cancel").cancelStyle()
            make.button("Go").handler { textFieldStrings in
                // Display the tab bar, or tell them it wasn't a valid user token.
                if YYIsValidPhoneNumber(textFieldStrings[0]) {
                    let phone = YYExtractFormattedPhoneNumber(textFieldStrings[0])!

                    // Display loading alert
                    let loading = TBAlertController(title: "One Moment…", message: nil)
                    loading.show(from: self.host)

                    DispatchQueue.main.async {
                        self.sendFakeNotificationPayload()
                    }
                    
                    self.client.startSignIn(withPhone: phone) { vid, error in
                        loading.dismiss(animated: true) {
                            if let error = error {
                                self.signInFailed(error)
                            } else {
                                self.promptForVerificationCode(vid!)
                            }
                        }
                    }
                } else {
                    self.notifyOfIncorrectPhoneFormat()
                }
            }
        }, showFrom: self.host)
    }

    private func promptForVerificationCode(_ verificationID: String) {
        TBAlert.make({ make in
            make.title("SMS Verification").message("Enter the code we sent you.")
            make.configuredTextField { textField in
                textField.placeholder = "6-digit code"
                textField.keyboardType = .phonePad
                textField.textContentType = .telephoneNumber
                textField.returnKeyType = .go
            }
            make.button("Cancel").cancelStyle()
            make.button("Verify").handler { strings in
                // Display loading alert
                let loading = TBAlertController(title: "One Moment…", message: nil)
                loading.show(from: self.host)

                self.client.verifyPhone(strings[0], identifier: verificationID) { error in
                    loading.dismiss(animated: true) {
                        if let error = error {
                            self.signInFailed(error)
                        } else {
                            self.didSignIn()
                        }
                    }
                }
            }
        }, showFrom: self.host)
    }
    
    private func didSignIn() {
        self.client.updateUser { error in
            if let error = error {
                self.signInFailed(error)
            } else {
                // Update location
                LocationManager.observeLocation { location in
                    self.client.location = location
                    
                    // Login callback, just once tho
                    if !self.onLogin.isEmpty {
                        self.onLogin.execute()
                        
                        // No more login callback on location update
                        LocationManager.observeLocation { location in
                            self.client.location = location
                        }
                    }
                }
            }
        }
    }
    
    private func notifyOfIncorrectPhoneFormat() {
        TBAlert.make({ make in
            make.title("Oops!")
            make.message("Looks like that wasn't a valid US phone number. Try again. Include your area code.")
            make.button("Dismiss").cancelStyle().handler { _ in
                self.promptForPhoneNumber()
            }
        }, showFrom: self.host)
    }

    private func signInFailed(_ error: Error) {
        TBAlert.make({ make in
            make.title("Sign In Failed").message(error.localizedDescription)
            make.button("Try Again").preferred().handler { _ in
                self.presentLoginForm()
            }
        }, showFrom: self.host)
    }
    
    private func notifyUserIsReady() {
//        feed?.refresh()
//        notifications?.refresh()
//        profile?.tableView.reloadData()
    }
}

private extension LoginController {
    func sendFakeNotificationPayload() {
        let payload: [AnyHashable: Any] = [
            "aps": ["content-available": 1],
            "com.google.firebase.auth": "{\"receipt\":\"AEFDNu_MuCzswAmn4y4401MHA5V55dLqw5uzU3R4EbMBaJnXQwZPEprOVofXvZRyrcGNFYXgRw6-yo-2HWmnhhqkgZ16Ljpz-Vj_t-1fBWi5jbiOYmUv2rTn\",\"secret\":\"ueMdbZs6YyWy5Wv7\"}",
            "gcm.message_id": 1660109226066618,
            "google.c.fid": "eEF20awPxvk",
            "google.c.sender.id": 884155835908,
        ]
        
        UIApplication.shared.appDelegate.application(.shared, didReceiveRemoteNotification: payload) { _ in }
    }
}
