//
//  ImageChip.swift
//  PhotoBoard
//
//  Created by Jed Fox on 12/9/21.
//

import SwiftUI
import Photos
import SFSafeSymbols

struct NoneButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct ImageChip: View {
    @StateObject var loader: ImageProvider
    let asset: PHAsset
    @Binding var selection: Set<UIImage>?

    @State private var copiedCount = 0

    init(asset: PHAsset, selection: Binding<Set<UIImage>?>) {
        self.asset = asset
        _loader = StateObject(wrappedValue: ImageProvider(asset: asset))
        _selection = selection
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
        GeometryReader { geom in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Group {
                        if geom.size.width > 100 {
                            Label("Copied!", systemSymbol: .docOnDoc)
                        } else {
                            VStack {
                                Image(systemSymbol: .docOnDoc)
                                Text("Copied!")
                            }
                        }
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(.thinMaterial)
                    .cornerRadius(7)
                    Spacer()
                }
                Spacer()
            }
            .transition(
                .asymmetric(insertion: .scale(scale: 1.25), removal: .scale(scale: 0.5))
                    .combined(with: .opacity)
            )
        }
    }

    private func copy() {
        copiedCount += 1
        UIPasteboard.general.image = loader.image
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            copiedCount -= 1
        }
    }

    private func toggle() {
        if var selection = self.selection,
            let image = loader.image {
            if selection.contains(image) {
                selection.remove(image)
            } else {
                selection.insert(image)
            }
            self.selection = selection
        }
    }

    var body: some View {
        Button(action: {
            if selection == nil {
                copy()
            } else {
                toggle()
            }
        }) {
            image
                .overlay { if copiedCount > 0 { copiedLabel } }
                .cornerRadius(10)
                .animation(.easeInOut(duration: 0.2), value: copiedCount)
        }
        .overlay(alignment: .bottomTrailing) {
            Group {
                if let selection = selection {
                    Button(action: toggle) {
                        Group {
                            if let image = loader.image, selection.contains(image) {
                                Image(systemSymbol: .checkmarkCircle)
                                    .foregroundStyle(.white, .blue)
                            } else {
                                Image(systemSymbol: .circle)
                                    .foregroundStyle(.ultraThinMaterial)
                            }
                        }
                        .symbolVariant(.fill)
                        .overlay(Image(systemSymbol: .circle).font(.title.weight(.light)).foregroundColor(.white))
                    }
                    .font(.title)
                    .imageScale(.large)
                    .shadow(radius: 5)
                    .transition(
                        .opacity
                            .combined(with: .scale(scale: 0.75))
                    )
                }
            }
            .offset(x: -5, y: -20)
            .buttonStyle(NoneButtonStyle())
        }
    }
}

