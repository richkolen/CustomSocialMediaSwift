//
//  SinglePostViewController.swift
//  Catenaccio
//
//  Created by Richard Kolen on 27-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var postId = ""
    var post = Post()
    var user = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPost() {
        Api.Post.observePosts(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.user = user
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePostCommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "SinglePostProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
    }
}

extension SinglePostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension SinglePostViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "SinglePostCommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "SinglePostProfileUserSegue", sender: userId)
    }
}



