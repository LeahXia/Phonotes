//
//  Photo.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

struct Photo {
    var photoId: String
    var photo: UIImage
    var photoDate: String
    var hasNote: Bool
    var noteTitle: String?
    var noteDetail: String?
    
    init(photoId: String = "123", photo: UIImage, photoDate: String, hasNote: Bool, noteTitle: String?, noteDetail: String?) {
        self.photoId = photoId
        self.photo = photo
        self.photoDate = photoDate
        self.hasNote = hasNote
        self.noteTitle = noteTitle
        self.noteDetail = noteDetail
    }
}
