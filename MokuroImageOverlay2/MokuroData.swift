//
//  MokuroData.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/01.
//

import Foundation
import CoreGraphics
import SwiftUI

// Extend CGPoint to make it hashable for usage in sets or as dictionary keys
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

// Decode each coordinate as a CGPoint
extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let coords = try container.decode([Double].self)
        guard coords.count == 2 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid number of coordinates")
        }
        self.init(x: coords[0], y: coords[1])
    }
}

// Define a structure for each "block" that contains the text and its properties
struct MokuroBlock: Identifiable, Hashable, Codable {
    var id = UUID() // Unique ID for each block
    var box: [CGFloat] // [x1, y1, x2, y2] for bounding box of the block
    var vertical: Bool // Whether the text is vertical
    var fontSize: CGFloat // The font size
    var linesCoords: [[[CGPoint]]] // Coordinates for each line of text
    var lines: [String] // The text content for each block
    
    // Custom keys for coding and decoding if needed
    enum CodingKeys: String, CodingKey {
        case box
        case vertical
        case fontSize = "font_size"
        case linesCoords = "lines_coords"
        case lines
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Ensure all stored properties are initialized
        self.box = try container.decode([CGFloat].self, forKey: .box)
        self.vertical = try container.decode(Bool.self, forKey: .vertical)
        self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        self.lines = try container.decode([String].self, forKey: .lines)
        
        let rawLinesCoords = try container.decode([[[CGFloat]]].self, forKey: .linesCoords)
        
        self.linesCoords = rawLinesCoords.map { line in
            line.compactMap { pair -> [CGPoint]? in
                guard pair.count == 2 else { return nil }
                return [CGPoint(x: pair[0], y: pair[1])]
            }
        }
    }
}

struct Page: Codable {
    var version: String
    var imgWidth: CGFloat
    var imgHeight: CGFloat
    var blocks: [MokuroBlock]
    var imgPath: String?
    
    enum CodingKeys: String, CodingKey {
        case version
        case imgWidth = "img_width"
        case imgHeight = "img_height"
        case blocks
        case imgPath = "img_path"
    }
}

// Define the main MokuroData model that will hold the entire data
struct MokuroData: Codable {
    var version: String
    var title: String
    var titleUUID: String
    var volume: String
    var volumeUUID: String
    var pages: [Page] // Array of pages in the mokuro file

    // Mapping keys for decoding to ensure proper translation
    enum CodingKeys: String, CodingKey {
        case version
        case title
        case titleUUID = "title_uuid"
        case volume
        case volumeUUID = "volume_uuid"
        case pages
    }
}


//    let mokuroData = MokuroData(
//        version: "0.2.1",
//        title: "Sample Title",
//        titleUUID: "5a7e32af-aa31-4a19-9f2c-db2c03af847c",
//        volume: "ラミアの黒魔術-20240726T054529Z-001",
//        volumeUUID: "8cc1531d-5569-44dd-a94c-5469426a67f5",
//        pages: [
//            Page(
//                version: "0.2.1",
//                imgWidth: 1488,
//                imgHeight: 2266,
//                blocks: [
//                    MokuroBlock(
//                        box: [1204, 948, 1260, 1177],
//                        vertical: true,
//                        fontSize: 55,
//                        linesCoords: [
//                            [
//                                CGPoint(x: 1204, y: 949),
//                                CGPoint(x: 1259, y: 949),
//                                CGPoint(x: 1259, y: 1177),
//                                CGPoint(x: 1204, y: 1177)
//                            ]
//                        ],
//                        lines: ["あーあ．．．"]
//                    ),
//                    MokuroBlock(
//                        box: [115, 1513, 359, 1814],
//                        vertical: true,
//                        fontSize: 52,
//                        linesCoords: [
//                            [
//                                CGPoint(x: 303, y: 1515),
//                                CGPoint(x: 358, y: 1515),
//                                CGPoint(x: 358, y: 1672),
//                                CGPoint(x: 303, y: 1672)
//                            ],
//                            [
//                                CGPoint(x: 243, y: 1515),
//                                CGPoint(x: 296, y: 1515),
//                                CGPoint(x: 296, y: 1814),
//                                CGPoint(x: 243, y: 1814)
//                            ],
//                            [
//                                CGPoint(x: 186, y: 1518),
//                                CGPoint(x: 232, y: 1518),
//                                CGPoint(x: 232, y: 1814),
//                                CGPoint(x: 186, y: 1814)
//                            ],
//                            [
//                                CGPoint(x: 115, y: 1513),
//                                CGPoint(x: 168, y: 1513),
//                                CGPoint(x: 172, y: 1717),
//                                CGPoint(x: 119, y: 1717)
//                            ]
//                        ],
//                        lines: ["なんで", "こんなことに", "なっちゃった", "んだろ．．．"]
//                    )
//                ],
//                imgPath: "IMG_0524"
//            )
//        ]
//    )


//let mokuroData2 = MokuroData(
//    version: "0.2.1",
//    imgWidth: 1488,
//    imgHeight: 2266,
//    blocks: [
//        MokuroBlock(
//            box: [1275, 75, 1392, 298],
//            vertical: true,
//            fontSize: 37,
//            linesCoords: [
//                [
//                    CGPoint(x: 1359.0, y: 81.0),
//                    CGPoint(x: 1390.0, y: 81.0),
//                    CGPoint(x: 1390.0, y: 298.0),
//                    CGPoint(x: 1359.0, y: 298.0)
//                ],
//                [
//                    CGPoint(x: 1315.0, y: 77.0),
//                    CGPoint(x: 1352.0, y: 77.0),
//                    CGPoint(x: 1352.0, y: 269.0),
//                    CGPoint(x: 1315.0, y: 269.0)
//                ],
//                [
//                    CGPoint(x: 1275.0, y: 75.0),
//                    CGPoint(x: 1317.0, y: 75.0),
//                    CGPoint(x: 1317.0, y: 177.0),
//                    CGPoint(x: 1275.0, y: 177.0)
//                ]
//            ],
//            lines: ["一人で本ばかり", "読んでたから", "かな．．．"]
//        ),
//        MokuroBlock(
//            box: [137, 123, 338, 323],
//            vertical: true,
//            fontSize: 46,
//            linesCoords: [
//                [
//                    CGPoint(x: 276.0, y: 123.0),
//                    CGPoint(x: 338.0, y: 123.0),
//                    CGPoint(x: 338.0, y: 216.0),
//                    CGPoint(x: 276.0, y: 216.0)
//                ],
//                [
//                    CGPoint(x: 241.0, y: 130.0),
//                    CGPoint(x: 279.0, y: 130.0),
//                    CGPoint(x: 279.0, y: 323.0),
//                    CGPoint(x: 241.0, y: 323.0)
//                ],
//                [
//                    CGPoint(x: 190.0, y: 130.0),
//                    CGPoint(x: 230.0, y: 130.0),
//                    CGPoint(x: 230.0, y: 283.0),
//                    CGPoint(x: 190.0, y: 283.0)
//                ],
//                [
//                    CGPoint(x: 137.0, y: 130.0),
//                    CGPoint(x: 181.0, y: 128.0),
//                    CGPoint(x: 188.0, y: 287.0),
//                    CGPoint(x: 143.0, y: 289.0)
//                ]
//            ],
//            lines: ["誰か", "話しかけて", "くれない", "かなあ．．．"]
//        ),
//        MokuroBlock(
//            box: [1298, 515, 1412, 710],
//            vertical: true,
//            fontSize: 33,
//            linesCoords: [
//                [
//                    CGPoint(x: 1366.0, y: 517.0),
//                    CGPoint(x: 1408.0, y: 515.0),
//                    CGPoint(x: 1412.0, y: 619.0),
//                    CGPoint(x: 1370.0, y: 621.0)
//                ],
//                [
//                    CGPoint(x: 1333.0, y: 517.0),
//                    CGPoint(x: 1366.0, y: 517.0),
//                    CGPoint(x: 1370.0, y: 710.0),
//                    CGPoint(x: 1337.0, y: 710.0)
//                ],
//                [
//                    CGPoint(x: 1299.0, y: 522.0),
//                    CGPoint(x: 1324.0, y: 522.0),
//                    CGPoint(x: 1324.0, y: 677.0),
//                    CGPoint(x: 1299.0, y: 677.0)
//                ]
//            ],
//            lines: ["本当は", "友達と一緒に", "勉強したり"]
//        ),
//        MokuroBlock(
//            box: [814, 606, 890, 796],
//            vertical: true,
//            fontSize: 34,
//            linesCoords: [
//                [
//                    CGPoint(x: 852.0, y: 606.0),
//                    CGPoint(x: 890.0, y: 606.0),
//                    CGPoint(x: 890.0, y: 796.0),
//                    CGPoint(x: 852.0, y: 796.0)
//                ],
//                [
//                    CGPoint(x: 814.0, y: 606.0),
//                    CGPoint(x: 845.0, y: 606.0),
//                    CGPoint(x: 845.0, y: 765.0),
//                    CGPoint(x: 814.0, y: 765.0)
//                ]
//            ],
//            lines: ["お揃いのペン", "買ったり．．．"]
//        )
//    ],
//    imgPath: "IMG_0525"
//)
