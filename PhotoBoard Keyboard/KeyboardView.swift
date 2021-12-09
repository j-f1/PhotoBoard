//
//  KeyboardView.swift
//  PhotoBoard Keyboard
//
//  Created by Jed Fox on 12/6/21.
//

import SwiftUI
import Photos

let data = Array(repeating: 0, count: 10).map { _ in CGFloat.random(in: (3/4)...(4/3)) }

struct FloatyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(radius: configuration.isPressed ? 5 : 10)
            .padding(.vertical)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
struct FillOnPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .symbolVariant(configuration.isPressed ? .fill : .none)
    }
}

struct KeyboardView: View {
    let proxy: UITextDocumentProxy

    @StateObject var provider = AssetProvider()
    @State var selection: Set<UIImage>?

    private var multiple: Bool { selection != nil }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 25) {
                    ForEach(provider.photos) { asset in
                        ImageChip(asset: asset, selection: $selection)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
            }
            .buttonStyle(FloatyButtonStyle())

            HStack {
                Button(action: {
                    if multiple {
                        selection = nil
                    } else {
                        selection = []
                    }
                }) {
                    Label {
                        Text("Select Multiple")
                            .font(.system(size: 18))
                            .opacity(multiple ? 1 : 0.5)
                    } icon: {
                        Image(systemName: "square.stack")
                            .foregroundColor(multiple ? Color(uiColor: .systemBackground) : .primary)
                            .scaleEffect(multiple ? 0.9 : 1)
                            .background(
                                Circle()
                                    .inset(by: -5)
                                    .fill(.primary)
                                    .scaleEffect(multiple ? 1 : 1.5)
                                    .opacity(multiple ? 1 : 0)
                            )
                    }
                }
//                .animation(.easeOut(duration: 0.2), value: multiple)
                Spacer()
                Button(action: proxy.deleteBackward) {
                    Image(systemName: "delete.backward")
                }
                .buttonStyle(FillOnPressButtonStyle())
            }
            .opacity(0.7)
            .font(.system(size: 21))
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
            .accentColor(.primary)
            .imageScale(.large)
        }
        .frame(width: 390, height: 278)
    }
}

//(27, 35)
//(26, 33.666666)
//(16.3333, 27) <- nope
//(16, 20.66666667)

class DemoProxy: NSObject, UITextDocumentProxy {
    override init() {
        super.init()
    }
    var documentContextBeforeInput: String?
    var documentContextAfterInput: String?
    var selectedText: String?
    var documentInputMode: UITextInputMode?
    var documentIdentifier = UUID()
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ markedText: String, selectedRange: NSRange) {}
    func unmarkText() {}
    var hasText = false
    func insertText(_ text: String) {}
    func deleteBackward() {}
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                KeyboardView(proxy: DemoProxy())
                Color.clear.frame(height: 58)
            }
            .background {
                Color(red: 209/255, green: 210/255, blue: 217/255)
            }
        }.ignoresSafeArea(edges: .bottom)
    }
}
