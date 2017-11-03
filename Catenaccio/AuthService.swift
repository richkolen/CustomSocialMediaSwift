//
//  AuthService.swift
//  Catenaccio
//
//  Created by Richard Kolen on 07-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    
    static func SignIn(email: String, password: String, onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSucces()
        })
    }
    
    static func SignUp(username: String, email: String, password: String, imageData: Data, onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error: Error?) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            let uid = user?.uid
            let storageReference = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            storageReference.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                let profileImageUrl = metadata?.downloadURL()?.absoluteString
                
                self.setUserInformation(profileImageUrl: profileImageUrl!, username: username, email: email, uid: uid!, onSucces: onSucces)
            })
        })
    }
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSucces: @escaping () -> Void) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased() ,"email": email, "profileImageUrl": profileImageUrl])
        onSucces()
    }
    
    static func updateUserInformation(username: String, email: String, imageData: Data, onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Api.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                let uid = Api.User.CURRENT_USER?.uid
                let storageReference = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
                
                storageReference.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    
                    self.updateUserInformationToDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, onSucces: onSucces, onError: onError)
                })
            }
        })
    }
    
    static func updateUserInformationToDatabase(profileImageUrl: String, username: String, email: String, onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username_lowercase": username.lowercased() ,"email": email, "profileImageUrl": profileImageUrl]
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSucces()
            }
        })
    }
    
    static func logOut(onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSucces()
        } catch let logOutError {
            onError(logOutError.localizedDescription)
        }
    }
    
}
