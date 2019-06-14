//
//  Photo.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit
import Photos

class Photo {
    var photoId: String
    var photo: UIImage
    var creationDate: Date?
    var asset: PHAsset
    var hasNote: Bool
    var noteTitle: String?
    var noteDetail: String?
    
    init(photoId: String, photo: UIImage, creationDate: Date?, asset: PHAsset, hasNote: Bool = false, noteTitle: String?, noteDetail: String?) {
        self.photoId = photoId
        self.photo = photo
        self.creationDate = creationDate
        self.asset = asset
        self.hasNote = hasNote
        self.noteTitle = noteTitle
        self.noteDetail = noteDetail
    }
    
    func getFormattedCreationDate() -> String {
        return "\(self.creationDate?.dateFormatterOfMonthDayYear() ?? "")"
    }
    
    func updateToLargePhoto(largePhoto: UIImage) {
        self.photo = largePhoto
    }
}
