//
//  Api.swift
//  Catenaccio
//
//  Created by Richard Kolen on 13-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import Foundation

struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPost = MyPostApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
}
