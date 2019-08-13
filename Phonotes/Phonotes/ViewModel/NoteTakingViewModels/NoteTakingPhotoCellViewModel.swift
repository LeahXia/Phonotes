//
//  NoteTakingPhotoCellViewModel.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-07-21.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

final class NoteTakingPhotoCellViewModel {
    
    var photo: UIImage?
    var hasNote: Bool = false
    var isSelected: Bool = false
    
    init(photo: Photo?, indexPath: IndexPath, selectedIndexPath: IndexPath) {
        if let photo = photo {
            self.photo = photo.photo
        } else if indexPath.item <= 5 {
            self.photo = UIImage(named: "BlurryImage\(indexPath.item + 1)")
        }
        
        self.hasNote = photo?.note?.hasNote ?? false
        self.isSelected = indexPath == selectedIndexPath
    }
    
    func updateCellViewModelNote(note: Note) {
        self.hasNote = note.hasNote
    }
}
