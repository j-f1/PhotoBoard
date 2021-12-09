//
//  KeyboardView.swift
//  PhotoBoard Keyboard
//
//  Created by Jed Fox on 12/6/21.
//

import SwiftUI

let data = Array(repeating: 0, count: 10).map { _ in CGFloat.random(in: (3/4)...(4/3)) }

struct FloatyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .cornerRadius(10)
            .shadow(radius: configuration.isPressed ? 5 : 12)
            .padding(.vertical)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct KeyboardView: View {
    @StateObject var provider = AssetProvider()
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 25) {
                ForEach(provider.photos) { asset in
                    Button(action: {}) {
                        AssetView(asset)
                    }
                }
            }
            .padding([.top, .horizontal], 10)
            .padding(.bottom, 5)
        }
        .frame(width: 390, height: 278)
        .buttonStyle(FloatyButtonStyle())
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView()
            .previewLayout(.sizeThatFits)
    }
}
