//
//  YomichanFormat.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import RealmSwift
import Zip

class YomichanDictionaryFormat {
    
    // Singleton instance
    static let shared = YomichanDictionaryFormat()
    
    private init() {}
    
    // MARK: - Custom Definition Widget
    func shouldUseCustomDefinitionWidget(_ definition: String) -> Bool {
        if let _ = try? JSONSerialization.jsonObject(with: Data(definition.utf8), options: []) {
            return true
        }
        return false
    }
    
    func getCustomDefinitionText(_ meaning: String) -> String {
        guard let jsonData = meaning.data(using: .utf8),
              let content = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
            return ""
        }
        
        guard let node = StructuredContent.processContent(content)?.toNode() else {
            return ""
        }
        
        let document = Document.createEmptyDocument()
        document.body.appendChild(node)
        
        document.querySelectorAll("li").forEach { element in
            guard let css = element.parent?.attributes["style"],
                  let text = element.textContent else { return }
            
            let name = css.split(separator: ";")
                .first(where: { $0.contains("list-style-type") })?
                .split(separator: ":")
                .last?
                .trimmingCharacters(in: .whitespaces) ?? "square"
            
            let counterStyle = CounterStyleRegistry.lookup(name)
            let counter = counterStyle.generateMarkerContent(0)
            element.textContent = "\(counter) \(text)"
        }
        
        document.querySelectorAll("table").forEach { $0.remove() }
        
        return BeautifulSoup(document.body.innerHTML ?? "").getText(separator: "\n")
    }
    
    // MARK: - Helper Methods
    func getStructuredContentHtml(content: Any) -> String {
        if let map = content as? [String: Any] {
            let tag = map["tag"] as? String
            let content = getStructuredContentHtml(content: map["content"] ?? "")
            let style = getStyle(styleMap: map["style"] as? [String: Any] ?? [:])
            return getNodeHtml(tag: tag, content: content, style: style)
        } else if let list = content as? [Any] {
            return list.map { getStructuredContentHtml(content: $0) }.joined()
        } else if let contentString = content as? String {
            return contentString
        }
        return ""
    }
    
    func getStyle(styleMap: [String: Any]) -> [String: String] {
        return styleMap.reduce(into: [String: String]()) { result, entry in
            let (key, value) = entry
            result[key.camelToKebabCase()] = "\(value)"
        }
    }
    
    func getNodeHtml(tag: String?, content: String, style: [String: String] = [:]) -> String {
        guard let tag = tag else { return content }
        
        var element = "<\(tag)"
        if !style.isEmpty {
            let styleString = style.map { "\($0): \($1)" }.joined(separator: "; ")
            element += " style=\"\(styleString)\""
        }
        element += ">\(content)</\(tag)>"
        return element
    }
    
    func processDefinition(definition: Any) -> String? {
        if let plainText = definition as? String {
            return plainText
        } else if let map = definition as? [String: Any] {
            switch map["type"] as? String {
            case "text":
                return map["text"] as? String
            case "structured-content", "image":
                if let content = map["content"] {
                    return String(data: try! JSONSerialization.data(withJSONObject: content, options: []), encoding: .utf8)
                }
            default:
                break
            }
        }
        return nil
    }
    
    // MARK: - Prepare Methods
    func prepareDirectoryYomichanFormat(params: PrepareDirectoryParams) {
        let zipURL = params.file
        let resourceDirectory = params.resourceDirectory
        
        // Extract ZIP archive
        do {
            try Zip.extractArchive(at: zipURL, to: resourceDirectory) { progress in
                params.sendImportCount(n: progress)
            }
        } catch {
            print("Failed to extract archive: \(error)")
        }
    }
    
    func prepareNameYomichanFormat(params: PrepareDirectoryParams) -> String? {
        let indexFilePath = params.resourceDirectory.appendingPathComponent("index.json")
        
        guard let data = try? Data(contentsOf: indexFilePath),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return (json["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Add more `prepareEntries`, `prepareTags`, `preparePitches`, `prepareFrequencies` methods following the above structure
}

// MARK: - String Extension for CamelCase to KebabCase
extension String {
    func camelToKebabCase() -> String {
        return unicodeScalars.reduce("") { result, scalar in
            let str = String(scalar)
            if CharacterSet.uppercaseLetters.contains(scalar) {
                return result + (result.isEmpty ? "" : "-") + str.lowercased()
            } else {
                return result + str
            }
        }
    }
}

// MARK: - Placeholder Classes for Dependencies
class Document {
    static func createEmptyDocument() -> Document {
        // Placeholder for HTML document creation
        return Document()
    }
    
    var body: BodyElement = BodyElement()
    func querySelectorAll(_ selector: String) -> [HTMLElement] { [] }
}

class BodyElement {
    var innerHTML: String? = nil
    func appendChild(_ node: Any) {}
}

class HTMLElement {
    var parent: HTMLElement?
    var attributes: [String: String] = [:]
    var textContent: String? = nil
    func remove() {}
}

class BeautifulSoup {
    init(_ html: String) {}
    func getText(separator: String) -> String { "" }
}

class CounterStyleRegistry {
    static func lookup(_ name: String) -> CounterStyle {
        return CounterStyle()
    }
}

class CounterStyle {
    func generateMarkerContent(_ index: Int) -> String {
        return "•"
    }
}
