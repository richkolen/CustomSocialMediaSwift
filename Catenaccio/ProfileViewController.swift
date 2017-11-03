//
//  ProfileViewController.swift
//  Catenaccio
//
//  Created by Richard Kolen on 06-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var user: UserModel!
    var posts: [Post] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchMyPost()
    }
    
    func fetchMyPost() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.MyPost.REF_MY_POST.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            Api.Post.observePosts(withId: snapshot.key, completion: {
                post in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
    
    func fetchUser() {
        Api.User.observeCurrentUser { (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSettingsSegue" {
            let settingVC = segue.destination as! SettingsTableViewController
            settingVC.delegate = self
        }
        
        if segue.identifier == "ProfileSinglePostSegue" {
            let singlePostVC = segue.destination as! SinglePostViewController
            let postId = sender as! String
            singlePostVC.postId = postId
        }

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

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegateSettings = self
        }
        return headerViewCell
    }
}

extension ProfileViewController: HeaderProfileCollectionReusableViewDelegateToSettings {
    func goToSettingsVC() {
        performSegue(withIdentifier: "ProfileSettingsSegue", sender: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

extension ProfileViewController: SettingsTableViewControllerDelegate {
    func updateProfileInformation() {
        self.fetchUser()
    }
}

extension ProfileViewController: PhotoCollectionViewCellDelegate {
    func goToSinglePostVC(postId: String) {
        performSegue(withIdentifier: "ProfileSinglePostSegue", sender: postId)
    }
}
