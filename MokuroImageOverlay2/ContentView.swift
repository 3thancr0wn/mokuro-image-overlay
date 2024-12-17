//
//  ContentView.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/01.
//

import SwiftUI

struct ContentView: View {
    @State private var mokuroData: MokuroData? = nil

    var body: some View {
        Group {
            if let mokuroData = mokuroData {
                ScrollViewPaging(pages: mokuroData.pages)
            } else {
                VStack {
                    Text("No pages available")
                        .foregroundColor(.gray)
                        .font(.headline)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .onAppear {
            loadMokuroData()
        }
        .ignoresSafeArea() // Fullscreen experience
    }
    
    /// Loads Mokuro data asynchronously.
    private func loadMokuroData() {
        DispatchQueue.global(qos: .background).async {
            let loadedData = MokuroUtils.loadMokuroData(fileName: "ラミアの黒魔術-20240726T054529Z-001")
            DispatchQueue.main.async {
                self.mokuroData = loadedData
            }
        }
    }
}

#Preview {
    ContentView()
}
