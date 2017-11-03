//
//  Post.swift
//  Catenaccio
//
//  Created by Richard Kolen on 09-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseAuth

class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var commentCount: Int?
    var likeCount: Int?
    var likes : Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio: CGFloat?
}

extension Post {
    static func transformPost (dict: [String: Any], key: String?) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.commentCount = dict["commentCount"] as? Int
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        
        return post
    }
}
