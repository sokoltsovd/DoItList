//
//  User.swift
//  DoItList
//
//  Created by Dmitry Sokoltsov on 14.09.2021.
//

import Foundation
import Firebase


struct AppUsers {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
