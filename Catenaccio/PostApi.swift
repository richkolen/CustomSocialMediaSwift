//
//  PostaApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 13-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostApi {
    var REF_POST = Database.database().reference().child("posts")
    
    func observePost(completion: @escaping (Post) -> Void) {
        REF_POST.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPost(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observePosts(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POST.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void) {
        REF_POST.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let newPost = Post.transformPost(dict: dict, key: child.key)
                    completion(newPost)
                }
            })
        })
    }
    
    func incrementLikes(postId: String, onSucces: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POST.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        })
        { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                onSucces(post)
            }
        }

    }
    
    func incrementCommentCount(postId: String, onSucces: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POST.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject] {
                
                var commentCount = post["commentCount"] as? Int ?? 0
                
                    commentCount += 1

                post["commentCount"] = commentCount as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        })
        { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                onSucces(post)
            }
        }
    }
}
