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
    private var fetchLimit = 20

    init() {
        fetchPhotos()
    }

    private func fetchPhotos() {
        DispatchQueue.global(qos: .userInitiated).async { [fetchLimit] in
            let fetchOpts = PHFetchOptions()
            fetchOpts.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
            fetchOpts.fetchLimit = fetchLimit
            let result = AssetResult(PHAsset.fetchAssets(with: .image, options: fetchOpts))

            DispatchQueue.main.async {
                self.photos = result
            }
        }
    }
}
