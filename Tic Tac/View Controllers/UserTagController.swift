//
//  UserTagController.swift
//  Tic Tac
//
//  Created by Tanner Bennett on 9/3/22.
//

import UIKit
import YakKit
import TBAlertController

class UserTagController {
    init(userIdentifier: String, emoji: String?) {
        self.userIdentifier = userIdentifier
        self.currentEmoji = emoji
        self.tag = UserTag.with(userID: userIdentifier)
    }
    
    let userIdentifier: String
    let currentEmoji: String?
    private var tag: UserTag?
    private var host: UIViewController!
    
    func show(from host: ContextualHost) {
        guard let nav = host.navigationController else { return }
        self.host = nav
        
        self.mainMenu()
    }
    
    // MARK: Helper methods
    
    /// Show an alert with the preconfigured title
    private func showAlert(configuration: (TBAlert) -> Void) {
        TBAlert.make { make in
            configuration(make)
        }.show(from: self.host)
    }
    
    
    private func navigationButtons(_ make: TBAlert) {
        make.button("Go Back").handler { _ in
            self.mainMenu()
        }
        
        make.button("Cancel").cancelStyle()
    }
    
    private func saveOrUpdate(_ tag: UserTag, insert: Bool) {
        if insert {
            try! Container.shared.insert(newUser: tag)
        }
        else {
            try! Container.shared.update(user: tag)
        }
    }
    
    // MARK: Menus
    
    private func mainMenu() {
        self.showAlert { make in
            make.title(self.currentEmoji ?? "[no emoji]")
                .message(self.userIdentifier)
                .message("\n\n")
                .message(self.tag?.longDescription ?? "Untagged user")
            
            make.button("Set Party").handler { _ in self.setParty() }
            make.button("Set Gender").handler { _ in self.setGender() }
            make.button("Set Note").handler { _ in self.setTag() }
            make.button("Dismiss").preferred()
        }
    }
    
    private func setTag() {
        self.showAlert { make in
            make.title("User Note")
            make.textField()
            
            make.button("Save Tag").preferred().handler { strings in
                let currentTag = self.tag
                
                let newTag = UserTag(
                    gender: currentTag?.gender,
                    party: currentTag?.party,
                    text: strings.first,
                    emoji: self.currentEmoji
                )
                
                newTag.id = self.userIdentifier
                self.saveOrUpdate(newTag, insert: currentTag == nil)
            }
            
            self.navigationButtons(make)
        }
    }
    
    private func setParty() {
        func saveParty(choice: UserTag.Party) {
            let currentTag = self.tag
            
            let newTag = UserTag(
                gender: currentTag?.gender,
                party: choice,
                text: currentTag?.text,
                emoji: self.currentEmoji
            )
            
            newTag.id = self.userIdentifier
            self.saveOrUpdate(newTag, insert: currentTag == nil)
        }
        
        self.showAlert { make in
            make.title("User's Political Affiliation")
            
            make.button("Conservative 🐘").handler { strings in
                saveParty(choice: .right)
            }
            make.button("Progressive 🧠").handler { strings in
                saveParty(choice: .left)
            }
            make.button("Unknown").handler { strings in
                saveParty(choice: .unknown)
            }
            
            self.navigationButtons(make)
        }
    }
    
    private func setGender() {
        func saveGender(choice: UserTag.Gender) {
            let currentTag = self.tag
            
            let newTag = UserTag(
                gender: choice,
                party: currentTag?.party,
                text: currentTag?.text,
                emoji: self.currentEmoji
            )
            
            newTag.id = self.userIdentifier
            self.saveOrUpdate(newTag, insert: currentTag == nil)
        }
        
        self.showAlert { make in
            make.title("User's Likely Gender")
            
            make.button("Male 👦🏻").handler { strings in
                saveGender(choice: .male)
            }
            make.button("Female 👱🏻‍♀️").handler { strings in
                saveGender(choice: .female)
            }
            make.button("Unknown").handler { strings in
                saveGender(choice: .unknown)
            }
            
            self.navigationButtons(make)
        }
    }
}
