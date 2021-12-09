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
            .onDrag {
                NSItemProvider(object: URL(string: "https://apple.com")! as NSURL)
            }
            .padding(.vertical)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct KeyboardView: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 25) {
                ForEach(data, id: \.self) { aspect in
                    Button(action: {}) {
                        Color.brown
                            .aspectRatio(aspect, contentMode: .fill)
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
