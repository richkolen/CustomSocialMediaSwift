//
//  HomeTableViewCell.swift
//  Catenaccio
//
//  Created by Richard Kolen on 11-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentImageview: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var captionDivider: NSLayoutConstraint!
    @IBOutlet weak var commentCountButton: UIButton!
    @IBOutlet weak var captionLabelTop: NSLayoutConstraint!
    @IBOutlet weak var captionLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    
    var delegate: HomeTableViewCellDelegate?
    var postId: String!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            setUpUserInfo()
        }
    }
    
    func updateView() {
        captionLabel.text = post?.caption
        
        checkCaptionForData()
        
//        Api.Post_Comment.fetchPostCommentCount(withId: post!.id!) { (count) in
//            if count != 0 {
//                self.commentCountButton.isHidden = false
//                self.commentCountButton.setTitle("\(count) comments", for: UIControlState.normal)
//            } else {
//                self.commentCountButton.isHidden = true
//            }
//
//        }
        if let ratio = post?.ratio {
            postImageViewHeight.constant = UIScreen.main.bounds.width / ratio
        }
        
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
        }
        
        self.updateLike(post: self.post!)
        self.updateCommentCount(post: self.post!)
    }
    
    func checkCaptionForData() {
        if captionLabel.text == "" {
            captionDivider.constant = 0
            //captionLabelTop.constant = 0
            //captionLabelBottom.constant = 0
        }
//        else {
//            captionDivider.constant = 1
//            captionLabelTop.constant = 10
//            captionLabelBottom.constant = 10
//        }
    }
        
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            likeCountButton.setTitle("\(count) likes", for: UIControlState.normal)
        } else {
            likeCountButton.setTitle("Be the first to like this", for: UIControlState.normal)
        }
    }
    
    func updateCommentCount(post: Post) {
        guard let count = post.commentCount else {
            return
        }
        if count != 0 {
            commentCountButton.isHidden = false
            commentCountButton.setTitle("\(count) comments", for: UIControlState.normal)
        } else {
            commentCountButton.isHidden = true
        }
    }

    
    func setUpUserInfo() {
        userNameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "user-placeholder")
        )}
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.text = ""
        captionLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageviewTouchUpInside))
        commentImageview.addGestureRecognizer(tapGesture)
        commentImageview.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageviewTouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureUserName = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelTouchUpInside))
        userNameLabel.addGestureRecognizer(tapGestureUserName)
        userNameLabel.isUserInteractionEnabled = true

    }
    
    func usernameLabelTouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
//    func changeLikeFastOnPress() {
//        let count = post?.likeCount ?? 0
//        if likeImageView.image == UIImage(named: "like") {
//            let newCount = count + 1
//            likeImageView.image = UIImage(named: "likeSelected")
//            likeCountButton.setTitle("\(newCount) likes", for: UIControlState.normal)
//        } else {
//            let newCount = count - 1
//            if newCount != 0 {
//                likeCountButton.setTitle("\(newCount) likes", for: UIControlState.normal)
//            } else {
//                likeCountButton.setTitle("Be the first to like this", for: UIControlState.normal)
//            }
//            likeImageView.image = UIImage(named: "like")
//        }
//    }
    
    func likeImageviewTouchUpInside() {
//        changeLikeFastOnPress()
        Api.Post.incrementLikes(postId: post!.id!, onSucces: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func commentCountButtonTouchUpInside(_ sender: Any) {
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    func commentImageviewTouchUpInside(){
        if let id = post?.id {
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "user-placeholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
