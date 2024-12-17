//
//  DictionaryUtils.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import RealmSwift
import Foundation

// MARK: - Utility Functions

/// FNV-1a 64bit hash algorithm optimized for Strings in Swift.
/// Generates a unique hash value for string inputs.
func fastHash(_ string: String) -> Int {
    var hash: UInt64 = 0xcbf29ce484222325
    for char in string.utf8 {
        hash ^= UInt64(char)
        hash &*= 0x100000001b3
    }
    return Int(truncatingIfNeeded: hash)
}

// MARK: - Helper Functions

/// Handles importing dictionary data with a prepared set of parameters.
func depositDictionaryDataHelper(_ params: PrepareDictionaryParams) async throws {
    do {
        // Open a Realm database instance in a specific directory.
        let configuration = Realm.Configuration(fileURL: URL(string: params.directoryPath),
                                                 schemaVersion: 1,
                                                 deleteRealmIfMigrationNeeded: true)
        let realm = try await Realm(configuration: configuration)

        // Write all entities in a single transaction.
        try realm.write {
            realm.add(params.dictionary, update: .all)

            params.dictionaryFormat.prepareTags(params: params, realm: realm)
            params.dictionaryFormat.prepareEntries(params: params, realm: realm)
            params.dictionaryFormat.preparePitches(params: params, realm: realm)
            params.dictionaryFormat.prepareFrequencies(params: params, realm: realm)
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        params.send("\(error.localizedDescription)")
        throw error
    }
}

/// Preloads linked entities for a specific search result by ID.
func preloadResultSync(id: Int) {
    do {
        let realm = try Realm()
        guard let result = realm.object(ofType: DictionarySearchResult.self, forPrimaryKey: id) else {
            return
        }

        let _ = result.headings.map { heading in
            let _ = heading.entries.map { entry in
                let _ = entry.dictionary
                let _ = entry.tags
            }
            let _ = heading.pitches
            let _ = heading.frequencies.map { frequency in
                let _ = frequency.dictionary
            }
            let _ = heading.tags
        }
    } catch {
        print("Error preloading results: \(error.localizedDescription)")
    }
}

/// Updates dictionary history with a new scroll position.
func updateDictionaryHistoryHelper(_ params: UpdateDictionaryHistoryParams) async throws {
    let configuration = Realm.Configuration(fileURL: URL(string: params.directoryPath),
                                             schemaVersion: 1,
                                             deleteRealmIfMigrationNeeded: true)
    let realm = try await Realm(configuration: configuration)

    guard let result = realm.object(ofType: DictionarySearchResult.self, forPrimaryKey: params.resultId) else {
        throw NSError(domain: "Realm", code: 404, userInfo: [NSLocalizedDescriptionKey: "Result not found"])
    }

    try realm.write {
        result.scrollPosition = params.newPosition
        realm.add(result, update: .modified)
    }
}

/// Clears all dictionary data from the database.
func deleteDictionariesHelper(_ params: DeleteDictionaryParams) async throws {
    let configuration = Realm.Configuration(fileURL: URL(string: params.directoryPath),
                                             schemaVersion: 1,
                                             deleteRealmIfMigrationNeeded: true)
    let realm = try await Realm(configuration: configuration)

    try realm.write {
        realm.deleteAll()
    }
}

/// Clears data for a single dictionary by ID.
func deleteDictionaryHelper(_ params: DeleteDictionaryParams) async throws {
    let configuration = Realm.Configuration(fileURL: URL(string: params.directoryPath),
                                             schemaVersion: 1,
                                             deleteRealmIfMigrationNeeded: true)
    let realm = try await Realm(configuration: configuration)

    guard let dictionary = realm.object(ofType: Dictionary.self, forPrimaryKey: params.dictionaryId) else {
        throw NSError(domain: "Realm", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dictionary not found"])
    }

    try realm.write {
        realm.delete(realm.objects(DictionarySearchResult.self).filter("dictionaryId == %@", dictionary.id))
        realm.delete(realm.objects(DictionaryEntry.self).filter("dictionary.id == %@", dictionary.id))
        realm.delete(realm.objects(DictionaryTag.self).filter("dictionary.id == %@", dictionary.id))
        realm.delete(realm.objects(DictionaryPitch.self).filter("dictionary.id == %@", dictionary.id))
        realm.delete(realm.objects(DictionaryFrequency.self).filter("dictionary.id == %@", dictionary.id))
        realm.delete(realm.objects(DictionaryHeading.self).filter("""
            entries.@count == 0 AND 
            tags.@count == 0 AND 
            pitches.@count == 0 AND 
            frequencies.@count == 0
        """))
        realm.delete(dictionary)
    }
}
