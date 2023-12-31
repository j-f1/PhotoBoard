//
//  AssetProvider.swift
//  PhotoBoard Keyboard
//
//  Created by Jed Fox on 12/9/21.
//

import Photos
import UIKit

struct AssetResult: RandomAccessCollection {
    private let result: PHFetchResult<PHAsset>?
    init(_ result: PHFetchResult<PHAsset>) {
        self.result = result
    }
    init() {
        result = nil
    }

    public func index(after i: Int) -> Int { i + 1 }
    public var startIndex: Int { 0 }
    public var endIndex: Int { result?.count ?? 0 }

    public subscript(index: Int) -> PHAsset {
        result!.object(at: index)
    }
}

extension PHAsset: Identifiable {
    public var id: String { localIdentifier }
}

@MainActor
class AssetProvider: ObservableObject {
    @Published var photos = AssetResult()
    private var fetchLimit = 5

    init() {}

    func loadMore() {
        fetchLimit += 5
        print("Trying \(fetchLimit)")
        fetchPhotos()
    }

    private func fetchPhotos() {
        DispatchQueue.global(qos: .userInitiated).async { [fetchLimit] in
            let recents = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)

            let fetchOpts = PHFetchOptions()
            fetchOpts.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
            fetchOpts.fetchLimit = fetchLimit
            fetchOpts.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)", argumentArray: [])
            let result = AssetResult(PHAsset.fetchAssets(in: recents.firstObject!, options: fetchOpts))

            DispatchQueue.main.async {
                self.photos = result
            }
        }
    }
}
