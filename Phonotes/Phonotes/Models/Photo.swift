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
    var note: Note?
    
    init(photoId: String, photo: UIImage, creationDate: Date?, asset: PHAsset, noteManager: NoteManager) {
        self.photoId = photoId
        self.photo = photo
        self.creationDate = creationDate
        self.asset = asset
        self.note = noteManager.getNote(by: photoId)
    }
    
    func getFormattedCreationDate() -> String {
        return "\(self.creationDate?.dateFormatterOfMonthDayYear() ?? "")"
    }
    
    func updateToLargePhoto(largePhoto: UIImage) {
        self.photo = largePhoto
    }
}
