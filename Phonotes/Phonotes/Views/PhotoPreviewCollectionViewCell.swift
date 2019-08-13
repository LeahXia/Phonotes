//
//  PhotoPreviewCollectionViewCell.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

final class PhotoPreviewCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var noteIndicator: UIView!
    
    func configCell(cellViewModel: NoteTakingPhotoCellViewModel?, indexPath: IndexPath) {
        guard let cellViewModel = cellViewModel else { return }
        photoImageView.image = cellViewModel.photo
        noteIndicator.isHidden = !cellViewModel.hasNote
        noteIndicator.layer.cornerRadius = 2
        if cellViewModel.isSelected {
            setBorder()
        }
    }
    
    fileprivate func setBorder() {
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = Colors.primaryColor.cgColor
    }
    
    fileprivate func removeBorder() {
        photoImageView.layer.borderWidth = 0
    }
    
    override func prepareForReuse() {
        removeBorder()
    }
}
