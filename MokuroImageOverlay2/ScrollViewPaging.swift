//
//  ScrollViewPaging.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/02.
//

import SwiftUI

struct ScrollViewPaging: View {
    var pages: [Page]

    var body: some View {
        TabView {
            ForEach(pages, id: \.self) { page in
                PageView(page: page)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .ignoresSafeArea() // For fullscreen presentation
    }
}

