//
//  DictionaryPitch.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import Foundation
import RealmSwift

/// A Realm model that represents supplementary pitch accent data for a certain search key.
class DictionaryPitch: Object {
    
    /// Identifier for database purposes.
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// Number that represents the index of the morae where the downstep occurs.
    @Persisted var downstep: Int
    
    /// This object pertains to a certain heading.
    /// Pending implementation: `DictionaryHeading` model.
    @Persisted(originProperty: "pitches") var heading: LinkingObjects<DictionaryHeading>
    
    /// This object belongs to a dictionary.
    /// Pending implementation: `Dictionary` model.
    @Persisted(originProperty: "pitches") var dictionary: LinkingObjects<Dictionary>
    
    /// Convenience initializer.
    convenience init(downstep: Int) {
        self.init()
        self.downstep = downstep
    }
    
    /// Overrides equality check for `DictionaryPitch`.
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DictionaryPitch else {
            return false
        }
        return self.id == other.id
    }
    
    /// Overrides hash computation for `DictionaryPitch`.
    override var hash: Int {
        return id.hashValue
    }
}

