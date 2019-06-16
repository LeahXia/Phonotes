//
//  NoteManager.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-15.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import Foundation
import RealmSwift

class NoteManager: NSObject {
    var realm: Realm?
    
    override init() {
        do {
            realm = try Realm()
        } catch {
            print("Initializing realm Error: ", error)
        }
    }
    
    func getNote(by photoId: String) -> Note? {
        let note = realm?.object(ofType: Note.self, forPrimaryKey: photoId)
        return note
    }
    
    func saveNote(photoId: String, noteTitle: String?, noteDetail: String?, completion: @escaping (String?) -> Void) {
        let note = Note()
        note.photoId = photoId
        note.hasNote = !(noteTitle?.isEmpty ?? true && noteDetail?.isEmpty ?? true)
        note.noteTitle = noteTitle
        note.noteDetail = noteDetail
        
        do {
            try realm?.write {
                realm?.add(note, update: .all)
                completion(nil)
            }
        } catch {
            completion(error.localizedDescription)
        }
        
    }
}
