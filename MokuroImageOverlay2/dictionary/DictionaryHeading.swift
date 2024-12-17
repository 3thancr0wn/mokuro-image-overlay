//
//  DictionaryHeading.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import RealmSwift

/// A Realm model that effectively acts as the primary key for a dictionary search.
/// Dictionary headings specify the term and reading and may point to multiple dictionary entries.
///
/// Dictionary keys are shared between multiple imported dictionaries.
class DictionaryHeading: Object {
    
    /// Identifier for database purposes.
    /// The ID is a computed hash based on the term and reading.
    var id: Int {
        return DictionaryHeading.hash(term: term, reading: reading)
    }
    
    /// Function to generate a lookup ID for heading by its unique string key.
    static func hash(term: String, reading: String) -> Int {
        return "\(term)/\(reading)".hashValue
    }
    
    /// A word or phrase. This effectively acts as the headword, or the primary
    /// concept to be learned or represented in a dictionary entry.
    @Persisted(indexed: true) var term: String
    
    /// An alternate form of the term. This is useful for languages which
    /// must distinguish different keys which share the same term but may
    /// have multiple pronunciations.
    @Persisted(indexed: true) var reading: String
    
    /// Term of the reading. Used for prioritizing starts-with matches.
    var termLength: Int {
        return term.count
    }
    
    /// A heading may have multiple dictionary entries.
    /// Pending implementation: `DictionaryEntry` model.
    @Persisted(originProperty: "heading") var entries: LinkingObjects<DictionaryEntry>
    
    /// A heading may have multiple pitch data.
    /// Pending implementation: `DictionaryPitch` model.
    @Persisted(originProperty: "heading") var pitches: LinkingObjects<DictionaryPitch>
    
    /// A heading may have multiple tags.
    /// Pending implementation: `DictionaryTag` model.
    @Persisted var tags: List<DictionaryTag>
    
    /// A heading may have multiple frequency data.
    /// Pending implementation: `DictionaryFrequency` model.
    @Persisted(originProperty: "heading") var frequencies: LinkingObjects<DictionaryFrequency>
    
    /// Convenience initializer.
    convenience init(term: String, reading: String = "") {
        self.init()
        self.term = term
        self.reading = reading
    }
    
    /// Sum of popularity of all dictionary entries belonging to this entry.
    /// This requires aggregation logic from `entries`.
    /// The implementation depends on the `DictionaryEntry` model.
    var popularitySum: Double {
        return entries.reduce(0.0) { $0 + ($1.popularity ?? 0.0) }
    }
    
    /// Overrides equality check for `DictionaryHeading`.
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DictionaryHeading else {
            return false
        }
        return self.term == other.term && self.reading == other.reading
    }
    
    /// Overrides hash computation for `DictionaryHeading`.
    override var hash: Int {
        return term.hashValue &* reading.hashValue
    }
}
