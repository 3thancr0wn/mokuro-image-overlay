//
//  ScrollViewPaging.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/02.
//

import SwiftUI

struct ScrollViewPaging: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<20) {index in
                    Rectangle()
                        .frame(width: 350, height: 620)
                        .overlay(Text("\(index)").foregroundColor(.white))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                    
                }
                
            }
        }
        .ignoresSafeArea()
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ScrollViewPaging()
}
