//
//  ImageProvider.swift
//  PhotoBoard
//
//  Created by Jed Fox on 12/9/21.
//

import SwiftUI
import Photos

class ImageProvider: ObservableObject {
    private static let manager = PHCachingImageManager()

    @Published var progress: Double = 0
    @Published var image: UIImage?

    private var requestID: PHImageRequestID?

    init(asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.progressHandler = { [weak self] (progress, error, stop, info) in
            self?.progress = progress
        }

        requestID = Self.manager.requestImage(
            for: asset,
               targetSize: CGSize(width: CGFloat.infinity, height: 263 * UIScreen.main.scale),
               contentMode: .aspectFit,
               options: options
        ) { [weak self] image, info in
            self?.image = image
        }
    }

    deinit {
        requestID.map(Self.manager.cancelImageRequest)
    }
}
