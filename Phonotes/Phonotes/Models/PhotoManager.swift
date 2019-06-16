//
//  PhotoManager.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-09.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import Foundation
import Photos

class PhotoManager: NSObject, PHPhotoLibraryChangeObserver {
    
    var fetchResult: PHFetchResult<PHAsset>?
    
    fileprivate let imageManager = PHCachingImageManager()
    var thumbnailSize: CGSize = .zero
    var largeImageViewSize = CGSize.zero
    
    func settingsForPhotoLibrary(largeImageViewSize: CGSize) {
        PHPhotoLibrary.shared().register(self)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        self.largeImageViewSize = largeImageViewSize
    }
    
    func fetchPhoto(forCell cell: PhotoPreviewCollectionViewCell, atIndexPath indexPath: IndexPath) -> Photo? {
        guard let asset = fetchResult?.object(at: indexPath.item) else { return nil }
        var photo: Photo?

        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier, let image = image {
                photo = Photo(photoId: asset.localIdentifier, photo: image, creationDate: asset.creationDate, asset: asset, noteTitle: nil, noteDetail: nil)
            }
        })
        return photo
    }

    func loadLargeImage(asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let options = self.setForUpdateImage()
        
        imageManager.requestImage(for: asset, targetSize: largeImageViewSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            
            guard let image = image else { return }
            
            completion(image)
        })
    }
    
    func setForUpdateImage() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        return options
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            if let fetchResult = fetchResult, let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                // Update the cached fetch result.
                self.fetchResult = changeDetails.fetchResultAfterChanges
            }
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                completion(true)
                break
            case .denied, .restricted:
                completion(false)
                break
            case .notDetermined:
                completion(false)
                break
            default:
                completion(false)
                break
            }
        }
    }
    
    func removePHPhotoObserver() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}
