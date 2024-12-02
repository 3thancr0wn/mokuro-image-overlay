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
    let imgWidth: CGFloat = 1488
    let imgHeight: CGFloat = 2266
    
    let mokuroData = MokuroData(
        version: "0.2.1",
        imgWidth: 1488,
        imgHeight: 2266,
        blocks: [
            MokuroBlock(
                box: [1204, 948, 1260, 1177],
                vertical: true,
                fontSize: 55,
                linesCoords: [
                    [
                        CGPoint(x: 1204, y: 949),
                        CGPoint(x: 1259, y: 949),
                        CGPoint(x: 1259, y: 1177),
                        CGPoint(x: 1204, y: 1177)
                    ]
                ],
                lines: ["あーあ．．．"]
            ),
            MokuroBlock(
                box: [115, 1513, 359, 1814],
                vertical: true,
                fontSize: 52,
                linesCoords: [
                    [
                        CGPoint(x: 303, y: 1515),
                        CGPoint(x: 358, y: 1515),
                        CGPoint(x: 358, y: 1672),
                        CGPoint(x: 303, y: 1672)
                    ],
                    [
                        CGPoint(x: 243, y: 1515),
                        CGPoint(x: 296, y: 1515),
                        CGPoint(x: 296, y: 1814),
                        CGPoint(x: 243, y: 1814)
                    ],
                    [
                        CGPoint(x: 186, y: 1518),
                        CGPoint(x: 232, y: 1518),
                        CGPoint(x: 232, y: 1814),
                        CGPoint(x: 186, y: 1814)
                    ],
                    [
                        CGPoint(x: 115, y: 1513),
                        CGPoint(x: 168, y: 1513),
                        CGPoint(x: 172, y: 1717),
                        CGPoint(x: 119, y: 1717)
                    ]
                ],
                lines: ["なんで", "こんなことに", "なっちゃった", "んだろ．．．"]
            )
        ],
        imgPath: "IMG_0524"
    )


    var body: some View {
        GeometryReader { geometry in
            let scaleX = geometry.size.width / imgWidth
            let scaleY = geometry.size.height / imgHeight
            
            ZStack {
                Image("IMG_05241")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                ForEach(mokuroData.blocks) { block in
                    let scaledBox = scaleBox(block.box, scaleX: scaleX, scaleY: scaleY)
                    
                    TategakiText(text: block.lines.joined(separator: "\n"))
                        .font(.system(size: block.fontSize * min(scaleX, scaleY)))
                        .frame(width: scaledBox.width, height: scaledBox.height)
                        .position(x: scaledBox.midX, y: scaledBox.midY)
                }
            }
        }
    }

    func scaleBox(_ box: [CGFloat], scaleX: CGFloat, scaleY: CGFloat) -> CGRect {
        let x1 = box[0] * scaleX
        let y1 = box[1] * scaleY
        let x2 = box[2] * scaleX
        let y2 = box[3] * scaleY
        return CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
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

public class TategakiTextView: UIView {
    public var text: String? = nil {
        didSet {
            ctFrame = nil
        }
    }
    
    private var ctFrame: CTFrame? = nil
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Flip the context to handle vertical text properly
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.height)
        
        // Function to calculate the max font size that fits within the rect
        func getMaxFontSizeThatFits(rect: CGRect, text: String) -> CGFloat {
            let testFontSize: CGFloat = 25  // Start with a standard font size
            var font = UIFont(name: "HiraginoSans-W3", size: testFontSize) ?? UIFont.systemFont(ofSize: testFontSize)
            
            var fontSize: CGFloat = testFontSize
            var textBoundingRect: CGRect
            
            repeat {
                // Measure the size of the text
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                textBoundingRect = attributedText.boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                                                               options: .usesLineFragmentOrigin,
                                                               context: nil)
                // If the text is too big, reduce the font size
                fontSize -= 1
                font = UIFont(name: "HiraginoSans-W3", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            } while textBoundingRect.height > rect.height // Ensure it fits within the rect's height
            
            return fontSize
        }
        
        // Get the maximum font size that fits the rect
        let fontSize = getMaxFontSizeThatFits(rect: rect, text: text ?? "")
        
        // Define the attributes for the text with the computed font size
        let font = UIFont(name: "HiraginoSans-W3", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .verticalGlyphForm: true // Ensures vertical text rendering
        ]
        
        // Create attributed string
        let attributedText = NSMutableAttributedString(string: text ?? "", attributes: baseAttributes)
        
        // Create the framesetter
        let setter = CTFramesetterCreateWithAttributedString(attributedText)
        
        // Create a path for the text frame
        let path = CGPath(rect: rect, transform: nil)
        
        // Frame attributes for right-to-left vertical text progression
        let frameAttrs = [
            kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue,
        ]
        
        // Create the frame with framesetter and path
        let ctFrame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, frameAttrs as CFDictionary)
        
        // Draw the frame (the actual text)
        CTFrameDraw(ctFrame, context)
        
        // Optionally, add a border around the rect for debugging
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2)
        context.stroke(rect)
    }


}

#Preview {
    ContentView()
}
