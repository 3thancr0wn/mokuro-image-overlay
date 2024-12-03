//
//  PageLayout.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/03.
//

import Foundation
import SwiftUI

struct PageLayout: Layout {
    var imgWidth: CGFloat
    var imgHeight: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Use the provided image dimensions as a base reference
        let width = proposal.width ?? imgWidth
        let height = width * (imgHeight / imgWidth) // Maintain aspect ratio
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        // Calculate scaling factors
        let scaleX = bounds.size.width / imgWidth
        let scaleY = bounds.size.height / imgHeight
        
        // Place each subview based on its associated block data
        for subview in subviews {
            // Extract block-specific metadata (passed via subview's tag)
            guard let block = subview[BlockLayoutKey.self] else { continue }
            
            let box = block.box
            let scaledBox = CGRect(
                x: box[0] * scaleX,
                y: box[1] * scaleY,
                width: (box[2] - box[0]) * scaleX,
                height: (box[3] - box[1]) * scaleY
            )
            
            // Propose a size for the subview and position it within the scaled bounding box
            subview.place(
                at: CGPoint(x: scaledBox.midX, y: scaledBox.midY),
                anchor: .center,
                proposal: ProposedViewSize(width: scaledBox.width, height: scaledBox.height)
            )
        }
    }
}

