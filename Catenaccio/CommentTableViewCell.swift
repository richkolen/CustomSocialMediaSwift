//
//  CommentTableViewCell.swift
//  Catenaccio
//
//  Created by Richard Kolen on 12-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?
    
    var comment: Comment? {
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
        commentLabel.text = comment?.commentText
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
        commentLabel.text = ""
        
        let tapGestureUserName = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelTouchUpInside))
        userNameLabel.addGestureRecognizer(tapGestureUserName)
        userNameLabel.isUserInteractionEnabled = true
    }
    
    func usernameLabelTouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
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
