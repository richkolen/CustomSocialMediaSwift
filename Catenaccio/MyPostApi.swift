//
//  MyPostApi.swift
//  Catenaccio
//
//  Created by Richard Kolen on 18-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation
import Foundation
import FirebaseDatabase

class MyPostApi {
    var REF_MY_POST = Database.database().reference().child("my-posts")
    
    func fetchMyPost(userId: String, completion: @escaping(String) -> Void) {
        REF_MY_POST.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchMyPostCount(userId: String, completion: @escaping(Int) -> Void) {
        REF_MY_POST.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
