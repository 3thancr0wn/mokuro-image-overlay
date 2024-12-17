//
//  StructuredContent.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import Foundation

/// Represents structured content for dictionary entries.
protocol StructuredContent {
    /// Convert content to a displayable string for rendering.
    func render() -> String
}

/// Represents plain text content.
struct StructuredContentTextNode: StructuredContent {
    /// The text content.
    let text: String
    
    /// Render text as a string.
    func render() -> String {
        return text
    }
}

/// Represents an image in structured content.
struct StructuredContentImage: StructuredContent {
    /// The image URL or path.
    let path: String
    
    /// Optional alt text for accessibility.
    let altText: String?
    
    /// Render image as an HTML-like string.
    func render() -> String {
        return "<img src='\(path)' alt='\(altText ?? "")' />"
    }
}

/// Represents a container for nested structured content.
struct StructuredContentContainer: StructuredContent {
    /// The tag type (e.g., `div`, `span`).
    let tag: String
    
    /// Optional styling for the container.
    let style: String?
    
    /// Nested child content.
    let children: [StructuredContent]
    
    /// Render the container as an HTML-like string.
    func render() -> String {
        let childContent = children.map { $0.render() }.joined(separator: "")
        return "<\(tag) style='\(style ?? "")'>\(childContent)</\(tag)>"
    }
}

/// Represents a styled container with custom attributes.
struct StructuredContentStyledContainer: StructuredContent {
    /// The tag type (e.g., `span`, `div`).
    let tag: String
    
    /// Styling applied to the container.
    let styles: [String: String]
    
    /// Nested child content.
    let children: [StructuredContent]
    
    /// Render the container with inline styles.
    func render() -> String {
        let styleString = styles.map { "\($0.key): \($0.value);" }.joined(separator: " ")
        let childContent = children.map { $0.render() }.joined(separator: "")
        return "<\(tag) style='\(styleString)'>\(childContent)</\(tag)>"
    }
}

/// Example usage for testing.
func testStructuredContentRendering() {
    let textNode = StructuredContentTextNode(text: "Hello, World!")
    let imageNode = StructuredContentImage(path: "example.png", altText: "Example Image")
    
    let container = StructuredContentContainer(
        tag: "div",
        style: "padding: 10px; background-color: lightgray;",
        children: [textNode, imageNode]
    )
    
    let styledContainer = StructuredContentStyledContainer(
        tag: "div",
        styles: ["margin": "10px", "border": "1px solid black"],
        children: [container]
    )
    
    print(styledContainer.render())
}
