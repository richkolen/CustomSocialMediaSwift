//
//  UserApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 13-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var REF_USER = Database.database().reference().child("users")
    
    func observeUser(withId uid: String, completion: @escaping (UserModel) -> Void){
        REF_USER.child(uid).observeSingleEvent(of: .value, with: {
        snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (UserModel) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USER.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (UserModel) -> Void) {
        REF_USER.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel.transformUser(dict: dict, key: snapshot.key)
                if user.id! != Api.User.CURRENT_USER?.uid {
                    completion(user)
                }
            }
        })
    }
    
    func queryUsers(withText text: String, completion: @escaping (UserModel) -> Void) {
        REF_USER.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = UserModel.transformUser(dict: dict, key: child.key)
                    completion(user)
                }

            })
        })
    }
    
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USER.child(currentUser.uid)
    }
}
