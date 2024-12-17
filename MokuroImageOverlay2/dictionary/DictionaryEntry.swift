//
//  DictionaryEntry.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import RealmSwift

class DictionaryEntry: Object {

    // Optional primary key using @Persisted(primaryKey: true)
    @Persisted(primaryKey: true) var id: String?

    // Properties using @Persisted
    @Persisted var definitions: List<String>
    @Persisted var popularity: Double
    @Persisted var headingTagNames: List<String> // Can be marked as @Ignored if not used
    @Persisted var entryTagNames: List<String> // Can be marked as @Ignored if not used
    @Persisted var imagePaths: List<String>
    @Persisted var audioPaths: List<String>
    @Persisted var extra: String?

    // Relationships (one-to-one) using @Persisted(relationship: .oneToOne)
    @Persisted(relationship: .oneToOne) var heading: DictionaryHeading // Assuming DictionaryHeading exists

    // Relationships (one-to-many) using @List
    @Persisted var dictionary: Dictionary // Assuming Dictionary exists
    @Persisted var tags: List<DictionaryTag> // Assuming DictionaryTag exists

    // Override default functions
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DictionaryEntry else { return false }
        return id == other.id
    }

    override var hash: Int {
        return id?.hashValue ?? 0
    }

    // Function to get compact definitions (can be moved to a separate class)
    func getCompactDefinitions() -> String {
        if definitions.count > 1 {
            return definitions.map { "• \($0.trimmingCharacters(in: .whitespacesAndNewlines))" }.joined(separator: "\n")
        } else {
            return definitions.joined().trimmed()
        }
    }
}
