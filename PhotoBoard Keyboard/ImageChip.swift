//
//  ImageChip.swift
//  PhotoBoard
//
//  Created by Jed Fox on 12/9/21.
//

import SwiftUI
import Photos

struct ImageChip: View {
    @StateObject var loader: ImageProvider
    let asset: PHAsset

    @State private var copiedCount = 0

    init(asset: PHAsset) {
        self.asset = asset
        _loader = StateObject(wrappedValue: ImageProvider(asset: asset))
    }

    @ViewBuilder private var image: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onDrag { NSItemProvider(object: image) }
        } else {
            Color.gray
                .aspectRatio(CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .fill)
        }
    }

    @ViewBuilder private var copiedLabel: some View {
        Label("Copied!", systemImage: "doc.on.doc")
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(.thinMaterial)
            .cornerRadius(7)
            .transition(
                .asymmetric(insertion: .scale(scale: 1.25), removal: .scale(scale: 0.5))
                    .combined(with: .opacity)
            )
    }

    private func copy() {
        copiedCount += 1
        UIPasteboard.general.image = loader.image
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            copiedCount -= 1
        }
    }

    var body: some View {
        Button(action: {
            copy()
        }) {
            image
                .overlay { if copiedCount > 0 { copiedLabel } }
                .animation(.easeInOut(duration: 0.2), value: copiedCount)
        }
    }
}

