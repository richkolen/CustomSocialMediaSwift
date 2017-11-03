//
//  Post_CommentApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 14-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post_CommentApi {
    var REF_POST_COMMENT = Database.database().reference().child("post-comments")
    
//    func fetchPostCommentCount(withId id: String, completion: @escaping(Int) -> Void) {
//        REF_POST_COMMENT.child(id).observe(.value, with: {
//            snapshot in
//            let count = Int(snapshot.childrenCount)
//            completion(count)
//        })
//    }
}
