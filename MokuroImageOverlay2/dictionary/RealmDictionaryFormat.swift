//
//  RealmDictionaryFormat.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import RealmSwift

class RealmDictionaryFormat: Object {
  @Persisted var uniqueKey: String
  @Persisted var name: String
  @Persisted var icon: String
  @Persisted var allowedExtensions: List<String>
  @Persisted var isTextFormat: Bool
  @Persisted var fileTypeRaw: String // Raw value for FileType enum

  var fileType: FileType {
    get { FileType(rawValue: fileTypeRaw) ?? .text }
    set { fileTypeRaw = newValue.rawValue }
  }

  // Non-persisted closures for asynchronous operations
  var prepareDirectory: ((PrepareDirectoryParams) async throws -> Void)?
  var prepareName: ((PrepareDirectoryParams) async throws -> String)?
  var prepareTags: ((PrepareDirectoryParams, Realm) -> Void)?
  var prepareEntries: ((PrepareDirectoryParams, Realm) -> Void)?
  var preparePitches: ((PrepareDirectoryParams, Realm) -> Void)?
  var prepareFrequencies: ((PrepareDirectoryParams, Realm) -> Void)?
}
