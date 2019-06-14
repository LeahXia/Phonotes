//
//  NoteTakingViewModel.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-08.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

class NoteTakingViewModel: NSObject {

    fileprivate(set) var selectedIndexPath: IndexPath? = IndexPath(item: 2, section: 0)
    fileprivate weak var vc: NoteTakingViewController?
    
    // Photo manager
    let photoManager = PhotoManager()
    lazy var photoCount = photoManager.fetchResult.count
    
    init(vc: NoteTakingViewController?) {
        self.vc = vc
    }
    
    func numberOfItems() -> Int {
        return photoCount
    }
    
    func getPhotoForCell(forCell cell: PhotoPreviewCollectionViewCell, atIndexPath indexPath: IndexPath) -> Photo? {
        let item = indexPath.item
        if item < 0 || item >= photoCount {
            return nil
        }
        
        guard let photo = photoManager.fetchPhoto(forCell: cell, atIndexPath: indexPath) else { return nil }
        
        return photo
    }
    
    func updateSelectedIndexPath(atIndexPath indexPath: IndexPath) {
        selectedIndexPath = indexPath
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
        let asset = photoManager.fetchResult.object(at: 2)
        photoManager.loadLargeImage(asset: asset) { [weak self] (image) in
            self?.vc?.largePhotoImageView.image = image
        }
    }
    
    func setThumbnailSizeForPhotoManager(size: CGSize) {
        photoManager.thumbnailSize = size
    }
}
