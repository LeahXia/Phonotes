//
//  Note.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-15.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var photoId: String = ""
    @objc dynamic var hasNote: Bool = false
    @objc dynamic var noteTitle: String?
    @objc dynamic var noteDetail: String?
    
    override class func primaryKey() -> String? {
        return "photoId"
    }
}
