//
//  ContentView.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/01.
//

import SwiftUI
import CoreText
import UIKit

struct ContentView: View {
    @State private var mokuroData: MokuroData? = nil
    
    var body: some View {
        GeometryReader { geometry in
            if let mokuroData = mokuroData {
                ScrollViewPaging(pages: mokuroData.pages)
            } else {
                Text("No pages available")
            }
        }
        .onAppear {
            mokuroData = MokuroUtils.loadMokuroData(fileName: "ラミアの黒魔術-20240726T054529Z-001")
        }
    }
}



public struct TategakiText: UIViewRepresentable {
    public var text: String?
    
    public func makeUIView(context: Context) -> TategakiTextView {
        let uiView = TategakiTextView()
        uiView.isOpaque = false
        uiView.text = text
        return uiView
    }
    
    public func updateUIView(_ uiView: TategakiTextView, context: Context) {
        uiView.text = text
    }
}

#Preview {
    ContentView()
}
