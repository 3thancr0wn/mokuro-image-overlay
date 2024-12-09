//
//  dictionary.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

// Import necessary frameworks
import Foundation
import RealmSwift


class Dictionary: Object {

  // Primary key using @Persisted(primaryKey: true)
  @Persisted(primaryKey: true) var id: String = ""

  // Properties using @Persisted
  @Persisted var name: String = ""
  @Persisted var formatKey: String = ""
  @Persisted var order: Int = 0

  // Relationships (one-to-many) using @List
  @Persisted var entries: List<DictionaryEntry>
  @Persisted var tags: List<DictionaryTag>
  @Persisted var pitches: List<DictionaryPitch>
  @Persisted var frequencies: List<DictionaryFrequency>

  // Initializer (using default init)
  override init() {}

  // Function to get base path with `URL` for better path handling
  func getBasePath(appDirDocPath: String) -> String {
      let url = URL(fileURLWithPath: appDirDocPath, isDirectory: true)
      return url.appendingPathComponent(name, isDirectory: true).path
  }

  // Function to check if dictionary is hidden for a language (using filter)
  func isHidden(language: Language) -> Bool {
      return entries.filter { $0.languageCode == language.rawValue }.isEmpty
  }

  // Function to check if dictionary is collapsed for a language (using filter)
  func isCollapsed(language: Language) -> Bool {
      return entries.filter { $0.languageCode == language.rawValue }.isEmpty
  }

  // Function to get resource path with `URL` for better path handling
  func getResourcePath(appDirDocPath: String, resourceBasename: String) -> String {
      let url = URL(fileURLWithPath: getBasePath(appDirDocPath: appDirDocPath), isDirectory: true)
      return url.appendingPathComponent(resourceBasename).path
  }

  // Override description
  override var description: String {
      return "Dictionary(name: \(name), format: \(formatKey))"
  }
}

// Implement equality check
extension Dictionary {
    static func == (lhs: Dictionary, rhs: Dictionary) -> Bool {
        return lhs.name == rhs.name
    }
}

// Implement hash function
extension Dictionary: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
