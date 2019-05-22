//
//  PhotoPreviewCollectionViewCell.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

class PhotoPreviewCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var noteIndicator: UIView!
   
    // MARK: - Variables
    var photo: Photo?
    
    func setupCell(photo: Photo) {
        self.photo = photo
        setStyle()
    }
    
    func setStyle() {
        noteIndicator.layer.cornerRadius = 2
        guard let photo = photo else { return }
        photoImageView.image = photo.photo
        noteIndicator.isHidden = !photo.hasNote
    }
    
    func setBorder() {
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = Colors.primaryColor.cgColor
    }
    
    func removeBorder() {
        photoImageView.layer.borderWidth = 0
    }
    
    override func prepareForReuse() {
        removeBorder()
    }
}
