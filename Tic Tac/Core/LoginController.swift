//
//  LoginController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 6/24/22.
//

import UIKit
import TBAlertController
import YakKit

struct LoginController {
    
    let host: UIViewController
    let client: YYClient
    
    private static var onLogin: (() -> Void)!
    
    func requireLogin(reset: Bool = false, _ completion: (() -> Void)?) {
        Self.onLogin = completion
        
        if reset {
            self.client.authToken = nil
            Defaults.standard.authToken = nil
        }
        
        // Require location first
        LocationManager.requireLocation { granted in
            if granted {
                if self.client.isLoggedIn || self.tryLocateAuthToken() {
                    self.didSignIn()
                } else {
                    self.presentLoginForm()
                }
            } else {
                // Recursively require location until granted
                LocationManager.presentLocationPermissionWarning(from: self.host) {
                    self.requireLogin(completion)
                }
            }
        }
    }
    
    @discardableResult
    private func tryLocateAuthToken() -> Bool {
        if let token = Defaults.standard.authToken {
            self.client.authToken = token
            return true
        }
        
        return false
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
                self.client.location = LocationManager.location
                Self.onLogin()
                Self.onLogin = nil
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
