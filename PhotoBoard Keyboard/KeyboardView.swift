//
//  KeyboardView.swift
//  PhotoBoard Keyboard
//
//  Created by Jed Fox on 12/6/21.
//

import SwiftUI
import Photos
import SFSafeSymbols

let data = Array(repeating: 0, count: 10).map { _ in CGFloat.random(in: (3/4)...(4/3)) }

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor {
            $0.userInterfaceStyle == .light ? UIColor(light) : UIColor(dark)
        })
    }
}

struct FloatyButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(radius: configuration.isPressed ? 5 : 10)
            .background {
                configuration.label
                    .blur(radius: configuration.isPressed ? 5 : 10)
                    .saturation(1.75)
                    .contrast(0.75)
                    .opacity(colorScheme == .dark ? 0.5 : 0.9)
                    .scaleEffect(0.98)
            }
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

@MainActor
struct KeyboardView: View {
    let proxy: UITextDocumentProxy

    @StateObject var provider = AssetProvider()
    @State var selection: Set<ImageProvider>?
    @State var didCopy = false

    private var multiple: Bool { selection != nil }

    @Environment(\.colorScheme) var colorScheme

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
                    Image(systemSymbol: .squareStack)
                        .foregroundColor(multiple ? Color(uiColor: .systemBackground) : .primary)
                        .scaleEffect(multiple ? 0.9 : 1)
                        .background(
                            Circle()
                                .inset(by: -5)
                                .fill(.primary)
                                .scaleEffect(multiple ? 1 : 0.5)
                                .opacity(multiple ? 1 : 0)
                                .shadow(color: .primary.opacity(colorScheme == .dark ? 0.3 : 0.5), radius: multiple ? 4 : 0)
                        )
                }
                Spacer()
                ZStack {
                    HStack {
                        if didCopy {
                            Label("Copied!", systemSymbol: .checkmark)
                                .transition(.opacity)
                                .font(.body)
                        }
                    }.animation(didCopy ? nil : .easeInOut(duration: 1), value: didCopy)
                    if let selection = selection {
                        Button(action: {
                            UIPasteboard.general.setItemProviders(selection.map(\.itemProvider), localOnly: false, expirationDate: nil)
                            self.selection = nil
                            self.didCopy = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                self.didCopy = false
                            }
                        }) {
                            Label("Copy \(selection.count) Photo\(selection.count == 1 ? "" : "s")", systemSymbol: .docOnDoc)
                                .symbolVariant(selection.isEmpty ? .none : .fill)
                                .foregroundColor(
                                    selection.isEmpty
                                    ? Color(light: .black, dark: .secondary)
                                    : Color(light: .white, dark: .black)
                                )
                        }
                        .disabled(selection.isEmpty)
                        .font(.system(size: 15))
                        .buttonStyle(.borderedProminent)
                        .transition(
                            .opacity
                                .combined(with: .scale(scale: 0.9))
                        )
                    }
                }
                Spacer()
                Button(action: { proxy.deleteBackward() }) {
                    Image(systemSymbol: .deleteBackward)
                }
                .buttonStyle(FillOnPressButtonStyle())
            }

            .opacity(colorScheme == .light ? 0.7 : 1)
            .font(.system(size: 21))
            .padding(.horizontal, 27)
            .padding(.bottom, 9.5)
            .accentColor(.primary)
            .imageScale(.large)
        }
        .animation(.easeInOut(duration: didCopy ? 0.35 : 0.15), value: multiple)
        .frame(height: 278)
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
                    .clipped()
                Color.clear.frame(height: 58)
            }
            .background {
                Color(light: Color(red: 209/255, green: 210/255, blue: 217/255),
                      dark: Color(red: 43/255, green: 43/255, blue: 43/255))
            }
        }.ignoresSafeArea(edges: .bottom)
    }
}
