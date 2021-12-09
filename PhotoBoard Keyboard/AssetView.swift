//
//  AssetView.swift
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
               targetSize: CGSize(width: CGFloat.infinity, height: 263),
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

struct AssetView: View {
    @StateObject var loader: ImageProvider
    let asset: PHAsset

    init(_ asset: PHAsset) {
        self.asset = asset
        _loader = StateObject(wrappedValue: ImageProvider(asset: asset))
    }

    var body: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onDrag {
                    NSItemProvider(object: image)
                }
        } else {
            Color.gray
                .aspectRatio(CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .fill)
        }
    }
}
