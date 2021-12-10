//
//  ImageProvider.swift
//  PhotoBoard
//
//  Created by Jed Fox on 12/9/21.
//

import SwiftUI
import Photos

@MainActor
class ImageProvider: NSObject, ObservableObject {
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.registerObject(ofClass: UIImage.self, visibility: .all) { completionHandler in

            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.resizeMode = .none

            let progress = Progress()
            progress.becomeCurrent(withPendingUnitCount: 1)
            Self.manager.requestImage(for: self.asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, info in
                completionHandler(image, nil)
            }
            progress.resignCurrent()
            return progress
        }
        return provider
    }

    private static let manager = PHCachingImageManager()

    @Published var progress: Double = 0
    @Published var image: UIImage?

    private let asset: PHAsset
    private var requestID: PHImageRequestID?

    init(asset: PHAsset) {
        self.asset = asset
        super.init()

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
