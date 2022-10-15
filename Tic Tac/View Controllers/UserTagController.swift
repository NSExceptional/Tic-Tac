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
            try! Container.shared.update(tag)
        }
    }
    
    // MARK: Menus
    
    private func mainMenu() {
        self.showAlert { make in
            make.title(self.currentEmoji ?? "[no emoji]")
                .message(self.userIdentifier)
                .message("\n\n")
                .message(self.tag?.longDescription ?? "Untagged user")
            
            make.button("Add Note").handler { _ in self.setTag() }
            make.button("🐘 Conservative").handler { strings in
                self.saveMetadata(party: .right)
            }
            make.button("🧠 Progressive").handler { strings in
                self.saveMetadata(party: .left)
            }
            make.button("👦🏻 Male").handler { strings in
                self.saveMetadata(gender: .male)
            }
            make.button("👱🏻‍♀️ Female").handler { strings in
                self.saveMetadata(gender: .female)
            }
            
            if self.tag != nil {
                make.button("More…").handler { _ in self.moreMenu() }
            }
            
            make.button("Dismiss").preferred()
        }
    }
    
    private func moreMenu() {
        precondition(self.tag != nil)
        
        self.showAlert { make in
            make.title(self.currentEmoji ?? "[no emoji]")
                .message(self.userIdentifier)
                .message("\n\n")
                .message(self.tag?.longDescription ?? "Untagged user")
            
            make.button("Un-Tag User").destructiveStyle().handler { _ in self.deleteUserTag() }
            make.button("Edit Known Emojis").handler { _ in self.setEmojis() }
            make.button("Clear Party/Gender").handler { strings in
                self.saveMetadata(party: .unknown, gender: .unknown)
            }
            
            self.navigationButtons(make)
        }
    }
    
    private func setTag() {
        self.showAlert { make in
            make.title("User Note")
            make.configuredTextField { field in
                field.autocorrectionType = .yes
                field.text = self.tag?.text
            }
            
            make.button("Save Tag").preferred().handler { strings in
                let currentTag = self.tag
                let tagText = strings.first ?? ""
                
                let newTag = UserTag(
                    gender: currentTag?.gender,
                    party: currentTag?.party,
                    text: tagText.isEmpty ? nil : tagText,
                    emoji: self.currentEmoji
                )
                
                newTag.id = self.userIdentifier
                self.saveOrUpdate(newTag, insert: currentTag == nil)
            }
            
            self.navigationButtons(make)
        }
    }
    
    private func setEmojis() {
        self.showAlert { make in
            make.title("Edit Known Emojis")
            make.configuredTextField { field in
                field.autocorrectionType = .no
                field.text = self.tag?.pastEmojis
            }
            
            make.button("Save").preferred().handler { strings in
                let currentTag = self.tag
                
                let newTag = UserTag(
                    gender: currentTag?.gender,
                    party: currentTag?.party,
                    text: currentTag?.text,
                    emoji: strings.first!
                )
                
                newTag.id = self.userIdentifier
                self.saveOrUpdate(newTag, insert: currentTag == nil)
            }
            
            self.navigationButtons(make)
        }
    }
    
    private func saveMetadata(party: UserTag.Party? = nil, gender: UserTag.Gender? = nil) {
        let currentTag = self.tag
        
        let newTag = UserTag(
            gender: gender ?? currentTag?.gender,
            party: party ?? currentTag?.party,
            text: currentTag?.text,
            emoji: self.currentEmoji
        )
        
        newTag.id = self.userIdentifier
        self.saveOrUpdate(newTag, insert: currentTag == nil)
    }
    
    private func deleteUserTag() {
        try! Container.shared.delete(self.tag!)
    }
}
