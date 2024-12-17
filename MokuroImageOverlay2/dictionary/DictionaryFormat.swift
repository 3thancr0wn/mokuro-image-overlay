//
//  DictionaryFormat.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import SwiftUI
import RealmSwift

protocol DictionaryFormat {
  // Protocol properties
  var uniqueKey: String { get }
  var name: String { get }
  var icon: String { get } // Assuming icons are represented as strings
  var allowedExtensions: [String] { get }
  var isTextFormat: Bool { get }
  var fileType: FileType { get } // Enum

  // Closures for asynchronous operations
  var prepareDirectory: ((PrepareDirectoryParams) async throws -> Void)? { get }
  var prepareName: ((PrepareDirectoryParams) async throws -> String)? { get }
  var prepareTags: ((PrepareDirectoryParams, Realm) -> Void)? { get }
  var prepareEntries: ((PrepareDirectoryParams, Realm) -> Void)? { get }
  var preparePitches: ((PrepareDirectoryParams, Realm) -> Void)? { get }
  var prepareFrequencies: ((PrepareDirectoryParams, Realm) -> Void)? { get }

  // Default implementations
  func customDefinitionWidget(context: UIViewController, ref: Any, definition: String) -> UIView
  func getCustomDefinitionText(meaning: String) -> String
  func shouldUseCustomDefinitionWidget(definition: String) -> Bool
}

// Provide default implementations
extension DictionaryFormat {
  func customDefinitionWidget(context: UIViewController, ref: Any, definition: String) -> UIView {
    return UIView()
  }

  func getCustomDefinitionText(meaning: String) -> String {
    return meaning
  }

  func shouldUseCustomDefinitionWidget(definition: String) -> Bool {
    return false
  }
}




// supporting type
struct PrepareDirectoryParams {
  // Define properties for PrepareDirectoryParams
  // Example:
  var directoryPath: String
  var fileName: String
}

//  supporting type
enum FileType {
  case text
  case binary
  case zip
  // Add more cases as needed
}
