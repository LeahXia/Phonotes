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
    var representedAssetIdentifier: String?
    var photo: Photo?
    
    func setupCell(photo: Photo?, indexPath: IndexPath, selectedIndexPath: IndexPath?) {
        if indexPath == selectedIndexPath {
            setBorder()
        }
        guard let photo = photo else {
            let index = indexPath.item
            if index <= 5 {
                photoImageView.image = UIImage(named: "BlurryImage\(index + 1)")
            }
            return
        }
        noteIndicator.layer.cornerRadius = 2
        photoImageView.image = photo.photo
        let hasNote = photo.note?.hasNote ?? false
        noteIndicator.isHidden = !hasNote
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
