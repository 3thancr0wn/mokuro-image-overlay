//
//  DictionaryFrequency.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/07.
//

import Foundation
import RealmSwift

/// A Realm model representing supplementary frequency data for a certain search key.
class DictionaryFrequency: Object {
    
    /// Identifier for database purposes.
    @Persisted(primaryKey: true) var id: ObjectId?
    
    /// Numerical representation of the frequency information.
    @Persisted var value: Double
    
    /// Text representation of the frequency information.
    @Persisted var displayValue: String
    
    /// This object belongs to a certain heading.
    /// Pending implementation: `DictionaryHeading` model.
    @Persisted var heading: LinkingObjects<DictionaryHeading>
    
    /// This object belongs to a dictionary.
    /// Pending implementation: `Dictionary` model.
    @Persisted var dictionary: LinkingObjects<Dictionary>
    
    /// Convenience initializer.
    convenience init(value: Double, displayValue: String, id: ObjectId? = nil) {
        self.init()
        self.id = id
        self.value = value
        self.displayValue = displayValue
    }
    
    /// Overrides equality check for `DictionaryFrequency`.
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DictionaryFrequency else {
            return false
        }
        return self.id == other.id
    }
    
    /// Overrides hash computation for `DictionaryFrequency`.
    override var hash: Int {
        return id?.hashValue ?? 0
    }
}
