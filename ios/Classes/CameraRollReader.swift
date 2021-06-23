//
//  CameraRollReader.swift
//  camera_roll_uploader
//
//  Created by Alfredo Rinaudo on 03/06/2021.
//

import Foundation
import UIKit
import Photos
import Flutter

class CameraRollReader: NSObject {
    
    fileprivate let imageManager = PHCachingImageManager()
    
    private func getFetchOptions() -> PHFetchOptions {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotosOptions.includeAssetSourceTypes = .typeUserLibrary
        allPhotosOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return allPhotosOptions
    }
    
    private func fetchAssets() -> PHFetchResult<PHAsset> {
        let options = getFetchOptions()
        return PHAsset.fetchAssets(with: options)
    }
    
    private func getRequestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.resizeMode = .exact
        requestOptions.version = .current
        requestOptions.isSynchronous = true
        requestOptions.normalizedCropRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        return requestOptions
    }
    
    func fetchAllPhotos(fetchCount: Int, cursor: Int, result: @escaping FlutterResult) {
        let allPhotos = fetchAssets()
        var dataImagesArray: [FlutterStandardTypedData] = []
        for i in cursor...(fetchCount + cursor) - 1 {
            let asset = allPhotos.object(at: i)
            imageManager.requestImage(for: asset,
                                      targetSize: CGSize(width: 200, height: 200),
                                      contentMode: .aspectFill,
                                      options: getRequestOptions(),
                                      resultHandler: { image, _ in
                                        if let image = image {
                                            if let data = image.pngData() {
                                                dataImagesArray.append(FlutterStandardTypedData(bytes: data))
                                                if i == (fetchCount + cursor) - 1 {
                                                    result(dataImagesArray)
                                                }
                                            }
                                        }
                                      })
        }
    }
    
    func selectPhoto(index: Int, result: @escaping FlutterResult) {
        let allPhotos = fetchAssets()
        let asset = allPhotos.object(at: index)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.version = .current
        options.progressHandler = { (progress, error, pointer, info) in
            //
        }
        
        var size: CGFloat = 800
        if let windowWidth = UIApplication.shared.keyWindow?.frame.size.width {
            size = windowWidth
        }
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: size,
                                                     height: size),
                                  contentMode: .aspectFill,
                                  options: options,
                                  resultHandler: { image, _ in
                                    let editOptions = PHContentEditingInputRequestOptions()
                                    editOptions.isNetworkAccessAllowed = true
                                    editOptions.progressHandler = { (progress, pointer) in
                                        //
                                    }
                                    asset.requestContentEditingInput(with: editOptions) { (input, info) in
                                        if let input = input {
                                            if let url = input.fullSizeImageURL {
                                                result(url.absoluteString.replacingOccurrences(of: "file://", with: ""))
                                            }
                                        }
                                    }
                                  })
    }
}
