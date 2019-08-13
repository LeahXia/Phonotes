//
//  NoteTakingViewModel.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-08.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

final class NoteTakingViewModel: NSObject {
    var photoCreatedData: String?
    var largePhoto: UIImage?
    var noteTitle: String?
    var noteDetail: String?
    var saveNoteError: String?

    fileprivate var photoManager: PhotoManager?
    fileprivate var noteManager: NoteManager?

    fileprivate(set) var selectedIndexPath: IndexPath = IndexPath(item: 2, section: 0)
    fileprivate var currentSelectedPhoto: Photo?
    fileprivate var thumbnailSize: CGSize = .zero

    fileprivate var cellViewModels = [Int: NoteTakingPhotoCellViewModel]()
    
    init(photoManager: PhotoManager?, noteManager: NoteManager) {
        self.photoManager = photoManager
        self.noteManager = noteManager
    }
}

// MARK: - PHPhoto
extension NoteTakingViewModel {
    
    func updatePhotoManager(largeImageViewSize: CGSize?) {
        guard photoManager == nil, let size = largeImageViewSize, let noteManager = noteManager else {
            return
        }
        photoManager = PhotoManager(largeImageViewSize: size, noteManager: noteManager)
    }
    
    func updateThumbnailSize(size: CGSize) {
        thumbnailSize = size
    }
    
    func updateSelectedIndexPath(atIndexPath indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func setCurrentSelectedPhoto(indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let photoCount = photoManager?.fetchResult?.count,
            indexPath.item < photoCount
        else {
            completion()
            return
        }
        
        // Load large image of the selected cell and assign it to largePhotoImageView
        guard let photo = photoManager?.fetchPhoto(atIndexPath: indexPath, targetSize: thumbnailSize) else { return }
        currentSelectedPhoto = photo
        photoManager?.loadLargeImage(asset: photo.asset) { [weak self] (image) in
            if let image = image {
                self?.currentSelectedPhoto?.photo = image
            }
            self?.setSelectedPhotoInfo()
            if let cellViewModel = self?.cellViewModels[indexPath.row] {
                cellViewModel.photo = image
            }
            completion()
        }
    }
    
    fileprivate func setSelectedPhotoInfo() {
        photoCreatedData = currentSelectedPhoto?.getFormattedCreationDate()
        largePhoto = currentSelectedPhoto?.photo
        if let note = currentSelectedPhoto?.note, note.hasNote {
            noteTitle = note.noteTitle
            noteDetail = note.noteDetail
        } else {
            noteTitle = ""
            noteDetail = Constants.defaultNoteDetail
        }
    }
    
    func saveNote(completion: @escaping (String?) -> Void) {
        guard let photo = currentSelectedPhoto else {
            completion("Cannot find selected photo")
            return
        }
        let noteDetailText = noteDetail == Constants.defaultNoteDetail ? "" : noteDetail
        noteManager?.saveNote(photoId: photo.photoId, noteTitle: noteTitle, noteDetail: noteDetailText) { [weak self] (note) in
            guard let note = note else {
                completion("Error: Save Note Failed")
                return
            }
            if let indexPath = self?.selectedIndexPath {
                self?.currentSelectedPhoto?.note = note
                guard let cellViewModel = self?.cellViewModels[indexPath.row] else { return }
                cellViewModel.updateCellViewModelNote(note: note)
            }
            completion(nil)
        }
    }
}

// MARK: - Photo Collection view model
extension NoteTakingViewModel {
    func numberOfItems() -> Int {
        return photoManager?.fetchResult?.count ?? 5
    }
    
    func getCellViewModel(atIndexPath indexPath: IndexPath) -> NoteTakingPhotoCellViewModel? {
        guard let photoCount = photoManager?.fetchResult?.count,
            indexPath.item < photoCount,
            let photo = photoManager?.fetchPhoto(atIndexPath: indexPath, targetSize: thumbnailSize)
        else {
            // Return a cellViewModel with a default blurry image
            return NoteTakingPhotoCellViewModel(photo: nil, indexPath: indexPath, selectedIndexPath: selectedIndexPath)
        }
        // Check for exsiting cellViewModel
        if let cellViewModel = cellViewModels[indexPath.row] {
            return cellViewModel
        }
        let cellViewModel = NoteTakingPhotoCellViewModel(photo: photo, indexPath: indexPath, selectedIndexPath: selectedIndexPath)
        cellViewModels[indexPath.row] = cellViewModel
        return cellViewModel
    }
}
