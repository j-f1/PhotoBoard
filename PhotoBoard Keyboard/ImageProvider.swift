//
//  ImageProvider.swift
//  PhotoBoard
//
//  Created by Jed Fox on 12/9/21.
//

import SwiftUI
import Photos

actor ProgressUpdater {
    @MainActor unowned let provider: ImageProvider
    init(provider: ImageProvider) {
        self.provider = provider
    }

    func setProgress(to progress: Double) async {
        await MainActor.run {
            provider.progress = progress
        }
    }
}

@MainActor
class ImageProvider: NSObject, ObservableObject {
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        let resource = PHAssetResource.assetResources(for: asset)
        let photo = (resource.first(where: { $0.type == .fullSizePhoto }) ?? resource.first(where: { $0.type == .photo }))!
        provider.registerFileRepresentation(forTypeIdentifier: photo.uniformTypeIdentifier, fileOptions: [], visibility: .all) { completionHandler in
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent(photo.originalFilename)

            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

                let opts = PHAssetResourceRequestOptions()
                opts.isNetworkAccessAllowed = true
                Self.assetManager.writeData(for: photo, toFile: url, options: opts) { error in
                    if let error = error {
                        completionHandler(nil, false, error)
                    } else {
                        completionHandler(url, false, error)
                    }
                }
            } catch {
                completionHandler(nil, false, error)
            }
            return nil
        }
        return provider
    }

    private static let imageManager = PHImageManager()
    private static let assetManager = PHAssetResourceManager()

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
        let updater = ProgressUpdater(provider: self)
        options.progressHandler = { (progress, error, stop, info) in
            Task {
                await updater.setProgress(to: progress)
            }
        }

        requestID = Self.imageManager.requestImage(
            for: asset,
               targetSize: CGSize(width: CGFloat.infinity, height: 263 * UIScreen.main.scale),
               contentMode: .aspectFit,
               options: options
        ) { [weak self] image, info in
            self?.image = image
        }
    }

    deinit {
        requestID.map(Self.imageManager.cancelImageRequest)
    }
}
