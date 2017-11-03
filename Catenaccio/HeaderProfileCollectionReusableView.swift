//
//  HeaderProfileCollectionReusableView.swift
//  Catenaccio
//
//  Created by Richard Kolen on 18-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: UserModel)
}

protocol HeaderProfileCollectionReusableViewDelegateToSettings {
    func goToSettingsVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegateSettings: HeaderProfileCollectionReusableViewDelegateToSettings?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        self.userNameLabel.text = user!.username
            
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        
        Api.MyPost.fetchMyPostCount(userId: user!.id!) { (count) in
            self.myPostsCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchFollowingCount(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchFollowersCount(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        if user?.id == Api.User.CURRENT_USER?.uid {
            followButton.setTitle("edit profile", for: UIControlState.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingsVC), for: UIControlEvents.touchUpInside)
        } else {
            updateStateFollowButton()
        }
    }
    
    func goToSettingsVC() {
        delegateSettings?.goToSettingsVC()
    }
    
    func updateStateFollowButton() {
        if user!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        layoutFollowButton()
        
        followButton.backgroundColor = UIColor.blue
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.setTitle("follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        layoutFollowButton()
        
        followButton.backgroundColor = UIColor.white
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.setTitle("following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    
    func followAction() {
        if user!.isFollowing! == false {
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user!.isFollowing! = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    func unFollowAction() {
        if user!.isFollowing! == true {
            Api.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    func layoutFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.backgroundColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
    }
}
