//
//  DictionaryTag.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import Foundation
import RealmSwift
import UIKit

/// A Realm model for tags, heavily based on the Yomichan format.
class DictionaryTag: Object {
    
    /// Identifier for database purposes.
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// Dictionary ID for hashing this tag.
    @Persisted var dictionaryId: Int
    
    /// Display name for the tag.
    @Persisted(indexed: true) var name: String
    
    /// Category for the tag.
    @Persisted var category: String
    
    /// Sorting order for the tag.
    @Persisted var sortingOrder: Int
    
    /// Notes for this tag.
    @Persisted var notes: String
    
    /// Score used to determine popularity.
    /// Negative values are more rare, and positive values are more frequent.
    @Persisted var popularity: Double
    
    /// A value is yielded from a single key.
    /// Pending implementation: `Dictionary` model.
    @Persisted(originProperty: "tags") var dictionary: LinkingObjects<Dictionary>
    
    /// Convenience initializer.
    convenience init(dictionaryId: Int, name: String, category: String, sortingOrder: Int, notes: String, popularity: Double) {
        self.init()
        self.dictionaryId = dictionaryId
        self.name = name
        self.category = category
        self.sortingOrder = sortingOrder
        self.notes = notes
        self.popularity = popularity
    }
    
    /// Factory initializer to create a tag for a dictionary.
    static func dictionary(dictionary: Dictionary) -> DictionaryTag {
        return DictionaryTag(
            dictionaryId: dictionary.id,
            name: dictionary.name,
            category: "frequent",
            sortingOrder: -100000000000,
            notes: "",
            popularity: 0
        )
    }
    
    /// Get the color for this tag based on its category.
    var color: UIColor {
        switch category {
        case "name": return UIColor(red: 0.83, green: 0.42, blue: 0.42, alpha: 1.0)
        case "expression": return UIColor(red: 1.0, green: 0.30, blue: 0.30, alpha: 1.0)
        case "popular": return UIColor(red: 0.33, green: 0.0, blue: 0.0, alpha: 1.0)
        case "partOfSpeech": return UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.0)
        case "archaism": return UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)
        case "dictionary": return UIColor(red: 0.63, green: 0.31, blue: 0.31, alpha: 1.0)
        case "frequency": return UIColor(red: 0.83, green: 0.42, blue: 0.42, alpha: 1.0)
        case "frequent": return UIColor(red: 0.50, green: 0.08, blue: 0.08, alpha: 1.0)
        default: return UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)
        }
    }
}
