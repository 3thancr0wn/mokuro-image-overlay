//
//  PageView.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/02.
//

import SwiftUI

struct PageView: View {
    @State private var mokuroData: MokuroData? = nil
    var page: Page  // This is a single page from mokuroData.pages
    var imgWidth: CGFloat
    var imgHeight: CGFloat
    
    var resolvedImagePath: String? {
        if let imgPath = page.imgPath?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // Normalize the extension to lowercase
            // TODO: needs to handle other img types
            let normalizedPath = imgPath.replacingOccurrences(of: ".PNG", with: ".png")
            return Bundle.main.url(forResource: normalizedPath, withExtension: nil)?.path
        }
        return nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Load the image using the imgPath in the page data
                if let resolvedPath = resolvedImagePath {
                    
                    Image(uiImage: UIImage(contentsOfFile: resolvedPath) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Text("Image not found")
                        .foregroundColor(.red)
                }
                // Loop through blocks on the page
                ForEach(page.blocks) { block in
                    let scaleX = geometry.size.width / imgWidth
                    let scaleY = geometry.size.height / imgHeight
                    let scaledBox = MokuroUtils.scaleBox(block.box, scaleX: scaleX, scaleY: scaleY)
                    
                    TategakiText(text: block.lines.joined(separator: "\n"))
                        .font(.system(size: block.fontSize * min(scaleX, scaleY)))
                        .frame(width: scaledBox.width, height: scaledBox.height)
                        .position(x: scaledBox.midX, y: scaledBox.midY)
                }
            }
        }
    }
}


