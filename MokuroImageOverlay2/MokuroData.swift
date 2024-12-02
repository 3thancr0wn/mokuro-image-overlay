//
//  MokuroData.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/01.
//

import Foundation
import SwiftUI

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
// Define a structure for each "block" that contains the text and its properties
struct MokuroBlock: Identifiable, Hashable, Codable {
    var id = UUID() // Unique ID for each block
    var box: [CGFloat] // [x1, y1, x2, y2] for bounding box of the block
    var vertical: Bool // Whether the text is vertical
    var fontSize: CGFloat // The font size
    var linesCoords: [[CGPoint]] // Coordinates for each line of text
    var lines: [String] // The text content for each block
}

// Define the main MokuroData model that will hold the entire data
struct MokuroData: Codable {
    var version: String
    var imgWidth: CGFloat
    var imgHeight: CGFloat
    var blocks: [MokuroBlock]
    var imgPath: String
}
