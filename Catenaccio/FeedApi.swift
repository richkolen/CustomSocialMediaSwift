//
//  FeedApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 20-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedApi {
    var REF_FEED = Database.database().reference().child("feed")
    
    func loadFeed(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                let key = child.key
                Api.Post.observePosts(withId: key, completion: { (post) in
                    completion(post)
                })

            })
        })
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observeSingleEvent(of: .childRemoved, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                let key = child.key
                Api.Post.observePosts(withId: key, completion: { (post) in
                    completion(post)
                })
                
            })
        })
    }
}

//func loadFeed(withId id: String, completion: @escaping (Post) -> Void) {
//    REF_FEED.child(id).observe(.childAdded, with: {
//        snapshot in
//        let key = snapshot.key
//        Api.Post.observePosts(withId: key, completion: { (post) in
//            completion(post)
//        })
//    })
//}

//func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void) {
//    REF_FEED.child(id).observe(.childRemoved, with: {
//        snapshot in
//        let key = snapshot.key
//        Api.Post.observePosts(withId: key, completion: { (post) in
//            completion(post)
//        })
//    })
//}


