//
//  NoteTakingViewModel.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-08.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

class NoteTakingViewModel: NSObject {

    fileprivate(set) var selectedIndexPath: IndexPath = IndexPath(item: 2, section: 0)
    fileprivate var currentSelectedPhoto: Photo?
    fileprivate let noteManager = NoteManager()
    fileprivate weak var vc: NoteTakingViewController?
    
    // Photo manager
    let photoManager = PhotoManager()
    
    init(vc: NoteTakingViewController?) {
        self.vc = vc
    }
    
    func numberOfItems() -> Int {
        return photoManager.fetchResult?.count ?? 5
    }
    
    func getPhotoForCell(forCell cell: PhotoPreviewCollectionViewCell, atIndexPath indexPath: IndexPath) -> Photo? {
        guard let photoCount = photoManager.fetchResult?.count,
            indexPath.item < photoCount else {
            return nil
        }
        
        let photo = photoManager.fetchPhoto(forCell: cell, atIndexPath: indexPath)
        
        return photo
    }
    
    func updateSelectedIndexPath(atIndexPath indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func getCurrentSelectedPhoto() -> Photo? {
        return currentSelectedPhoto
    }
    
    func setCurrentSelectedPhoto(cell: PhotoPreviewCollectionViewCell, indexPath: IndexPath) {
        let photo = getPhotoForCell(forCell: cell, atIndexPath: indexPath)
        self.currentSelectedPhoto = photo
    }
}

// MARK: - PHPhoto
extension NoteTakingViewModel {
    func loadLargeImage(for photo: Photo, completion: @escaping (_ largePhoto: UIImage) -> Void) {
        photoManager.loadLargeImage(asset: photo.asset) { (image) in
            photo.updateToLargePhoto(largePhoto: image)
            completion(image)
        }
    }
    
    func initPhotoLibrary() {
        photoManager.settingsForPhotoLibrary(largeImageViewSize: vc?.view.bounds.size ?? .zero)
        setInitPhoto()
    }
    
    func setInitPhoto() {
        guard let fetchResult = photoManager.fetchResult,
            fetchResult.count > 0
        else { return }

        let asset = fetchResult.count > 4 ? fetchResult.object(at: 2) : fetchResult.object(at: 0)
        photoManager.loadLargeImage(asset: asset) { [weak self] (image) in
            self?.vc?.largePhotoImageView.image = image
            let photo = Photo(photoId: asset.localIdentifier, photo: image, creationDate: asset.creationDate, asset: asset)
            self?.currentSelectedPhoto = photo
            self?.vc?.populateViewWithSelectedPhotoInfo()
        }
    }
    
    func setThumbnailSizeForPhotoManager(size: CGSize) {
        photoManager.thumbnailSize = size
    }
    
    func saveNote(completion: @escaping (String?) -> Void) {
        guard let photo = getCurrentSelectedPhoto() else { return }
        let noteDetail = vc?.noteDetailTextView.text == Constants.defaultNoteDetail ? "" : vc?.noteDetailTextView.text
        noteManager.saveNote(photoId: photo.photoId, noteTitle: vc?.noteTitleTextField.text, noteDetail: noteDetail) { (errorMessage) in
            completion(errorMessage)
        }
    }
}
