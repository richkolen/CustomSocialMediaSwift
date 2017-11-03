//
//  DiscoverUsersTableViewCell.swift
//  Catenaccio
//
//  Created by Richard Kolen on 20-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
protocol DiscoverUsersTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
}

class DiscoverUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: DiscoverUsersTableViewCellDelegate?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        userNameLabel.text = user?.username
        
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "user-placeholder")
        )}
        
        if user!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
        
        if user?.id! == (Api.User.CURRENT_USER?.uid)! {
            self.followButton.isHidden = true
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
        }
    }
    
    func unFollowAction() {
        if user!.isFollowing! == true {
            Api.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
        }
    }
    
    func layoutFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.backgroundColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureUserName = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelTouchUpInside))
        userNameLabel.addGestureRecognizer(tapGestureUserName)
        userNameLabel.isUserInteractionEnabled = true
    }
    
    func usernameLabelTouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
