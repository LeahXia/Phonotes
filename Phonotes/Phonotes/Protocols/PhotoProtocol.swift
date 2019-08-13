//
//  PhotoProtocol.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-08-09.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit
import Photos

protocol PhotoManagerProtocol {
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void)
    func removePHPhotoObserver(observer: PHPhotoLibraryChangeObserver)
}

extension PhotoManagerProtocol {
    
    func isPhotoLibraryAccessAllowed() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
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
    
    func removePHPhotoObserver(observer: PHPhotoLibraryChangeObserver) {
        PHPhotoLibrary.shared().unregisterChangeObserver(observer)
    }
}
