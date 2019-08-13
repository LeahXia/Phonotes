//
//  PhotoManager.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-09.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import Foundation
import Photos

final class PhotoManager: NSObject, PHPhotoLibraryChangeObserver, PhotoManagerProtocol {
    
    fileprivate var noteManager: NoteManager?
    
    fileprivate let imageManager = PHCachingImageManager()
    
    var fetchResult: PHFetchResult<PHAsset>?
    
    fileprivate var largeImageViewSize = CGSize.zero

    init(largeImageViewSize: CGSize, noteManager: NoteManager) {
        super.init()
        PHPhotoLibrary.shared().register(self)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        self.largeImageViewSize = largeImageViewSize
        self.noteManager = noteManager
    }
    
    func fetchPhoto(atIndexPath indexPath: IndexPath, targetSize: CGSize?) -> Photo? {
        guard let asset = fetchResult?.object(at: indexPath.item) else { return nil }

        var photo: Photo?
        guard let size = targetSize == nil ? largeImageViewSize : targetSize else { return nil }
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: {[weak self] image, _ in
            if let image = image, let noteManager = self?.noteManager {
                photo = Photo(photoId: asset.localIdentifier, photo: image, creationDate: asset.creationDate, asset: asset, noteManager: noteManager)
            }
        })
        return photo
    }

    func loadLargeImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = self.setPHImageRequestOptions()
        
        imageManager.requestImage(for: asset, targetSize: largeImageViewSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            completion(image)
        })
    }
    
    fileprivate func setPHImageRequestOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        return options
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let fetchResult = fetchResult, let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                // Update the cached fetch result.
                self.fetchResult = changeDetails.fetchResultAfterChanges
            }
        }
    }
}
