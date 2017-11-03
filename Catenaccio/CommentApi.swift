//
//  CommentApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 13-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    var REF_COMMENT = Database.database().reference().child("comments")
    
    func observeComment(withPostId id: String, completion: @escaping (Comment) -> Void){
        REF_COMMENT.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }

        })
    }
}
