//
//  PageView.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/02.
//

import SwiftUI

struct PageView: View {
    var page: Page  // Single page from `MokuroData`

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
            ZStack(alignment: .center) {
                // Render the page image
                if let resolvedPath = resolvedImagePath {
                    Image(uiImage: UIImage(contentsOfFile: resolvedPath) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Text("Image not found")
                        .foregroundColor(.red)
                }

                // Render the blocks using PageLayout
                PageLayout(imgWidth: CGFloat(page.imgWidth), imgHeight: CGFloat(page.imgHeight)) {
                    ForEach(page.blocks) { block in
                        TategakiText(text: block.lines.joined(separator: "\n"))
                            .font(.system(size: block.fontSize))
                            .layoutValue(key: BlockLayoutKey.self, value: block) // Attach block data
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
