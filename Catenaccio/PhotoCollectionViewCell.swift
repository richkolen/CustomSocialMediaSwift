//
//  PhotoCollectionViewCell.swift
//  Catenaccio
//
//  Created by Richard Kolen on 18-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit
protocol PhotoCollectionViewCellDelegate {
    func goToSinglePostVC(postId: String)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: PhotoCollectionViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl)
        }
        
        let tapGesturePhoto = UITapGestureRecognizer(target: self, action: #selector(self.photoTouchUpInside))
        photo.addGestureRecognizer(tapGesturePhoto)
        photo.isUserInteractionEnabled = true
    }
    
    func photoTouchUpInside() {
        if let id = post?.id {
            delegate?.goToSinglePostVC(postId: id)
        }
    }
}
