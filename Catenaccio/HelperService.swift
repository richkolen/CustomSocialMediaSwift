//
//  HelperService.swift
//  Catenaccio
//
//  Created by Richard Kolen on 19-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSucces: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            uploadVideoToStorage(videoUrl: videoUrl, onSucces: { (videoUrl) in
                uploadImageToStorage(data: data, onSucces: { (thumbnailImageUrl) in
                    self.sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSucces: onSucces)
                })
            })
        } else {
            uploadImageToStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSucces: onSucces)
            }
        }
    }
    
    static func uploadVideoToStorage(videoUrl: URL, onSucces: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageReference = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        storageReference.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                onSucces(videoUrl)
            }
        }
    }
    
    static func uploadImageToStorage(data: Data, onSucces: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageReference = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageReference.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSucces(photoUrl)
            }
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSucces: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POST.childByAutoId().key
        let newPostReference = Api.Post.REF_POST.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0, "commentCount": 0, "ratio": ratio] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    Api.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)": true])
                })
            })
            
            let myPostRef = Api.MyPost.REF_MY_POST.child(currentUserId).child(newPostId)
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Goal!")
            onSucces()
        })
    }
}
