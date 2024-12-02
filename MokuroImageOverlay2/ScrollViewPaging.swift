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
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(pages, id: \.self) {page in
//                    Rectangle()
//                        .frame(width: 350, height: 620)
//                        .overlay(Text("\(index)").foregroundColor(.white))
//                        .frame(maxWidth: .infinity)
//                        .padding(10)
//                        .containerRelativeFrame(.horizontal, alignment: .center)
                    PageView(page: page, imgWidth: page.imgWidth, imgHeight: page.imgHeight)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .padding(10)
                    
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

//#Preview {
//    ScrollViewPaging(pages: <#[Page]#>, imgWidth: <#CGFloat#>, imgHeight: <#CGFloat#>)
//}
