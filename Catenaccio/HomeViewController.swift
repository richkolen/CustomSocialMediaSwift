//
//  HomeViewController.swift
//  Catenaccio
//
//  Created by Richard Kolen on 06-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var users = [UserModel]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
    
        loadPosts()
    
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
        
    func refresh() {
        self.posts.removeAll()
        self.users.removeAll()
        self.tableView.reloadData()
        Api.Feed.loadFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.posts.append(post)
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
        }
        
//        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
//            self.posts = self.posts.filter { $0.id != post.id }
//            self.users = self.users.filter { $0.id != post.uid }
//            self.tableView.reloadData()
//        }
    }
    
        func loadPosts() {
            activityIndicatorView.startAnimating()
            Api.Feed.loadFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
                guard let postUid = post.uid else {
                    return
                }
                self.fetchUser(uid: postUid, completed: {
                    self.posts.append(post)
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                })
        }
    
//    func loadPosts() {
//        activityIndicatorView.startAnimating()
//        Api.Feed.loadFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
//            guard let postId = post.uid else {
//                return
//            }
//            self.fetchUser(uid: postId, completed: {
//                self.posts.append(post)
//                self.activityIndicatorView.stopAnimating()
//                self.tableView.reloadData()
//        })
//    }
    
//        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
//            self.posts = self.posts.filter { $0.id != post.id }
//            self.users = self.users.filter { $0.id != post.uid }
//            self.tableView.reloadData()
//        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.append(user)
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "HomeToProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "HomeToProfileSegue", sender: userId)
    }
}




