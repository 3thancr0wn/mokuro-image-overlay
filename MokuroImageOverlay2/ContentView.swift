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
    @State private var mokuroData: MokuroData? = nil
    let imgWidth: CGFloat = 1488
    let imgHeight: CGFloat = 2266
    
    var body: some View {
        
//        if let mokuroData = mokuroData {
//                        // Use the mokuroData to display information
//                        Text("Version: \(mokuroData.version)")
//                        // For example, loop through blocks
//                        ForEach(mokuroData.blocks, id: \.id) { block in
//                            Text(block.lines.joined(separator: " "))
//                        }
//                    } else {
//                        Text("Loading...")
//                    }
//        
        GeometryReader { geometry in
            // Ensure mokuroData is unwrapped safely
            if let mokuroData = mokuroData, let firstPage = mokuroData.pages.first {
                let scaleX = geometry.size.width / firstPage.imgWidth
                let scaleY = geometry.size.height / firstPage.imgHeight
                
                ZStack {
                    // Background image (scaled to fit the geometry)
                    Image("IMG_0525") // Assuming you have this image in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    // Loop through blocks in the first page
                    ForEach(firstPage.blocks) { block in
                        let scaledBox = scaleBox(block.box, scaleX: scaleX, scaleY: scaleY)
                        
                        TategakiText(text: block.lines.joined(separator: "\n"))
                            .font(.system(size: block.fontSize * min(scaleX, scaleY)))
                            .frame(width: scaledBox.width, height: scaledBox.height)
                            .position(x: scaledBox.midX, y: scaledBox.midY)
                    }
                }
            } else {
                Text("No pages available")
            }
        }
        .onAppear {
            loadMokuroData()
        }
    }
    
    func loadMokuroData() {
        // Use MokuroFileHandler to read and decode the .mokuro file
        if let fileURL = Bundle.main.url(forResource: "ラミアの黒魔術-20240726T054529Z-001", withExtension: "mokuro") {
            if let loadedData = MokuroFileHandler.loadMokuroData(from: fileURL) {
                self.mokuroData = loadedData
            } else {
                print("Failed to load .mokuro file.")
            }
        } else {
            print("File not found in the bundle.")
        }
    }

    func scaleBox(_ box: [CGFloat], scaleX: CGFloat, scaleY: CGFloat) -> CGRect {
            let x = box[0] * scaleX
            let y = box[1] * scaleY
            let width = (box[2] - box[0]) * scaleX
            let height = (box[3] - box[1]) * scaleY
            return CGRect(x: x, y: y, width: width, height: height)
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
