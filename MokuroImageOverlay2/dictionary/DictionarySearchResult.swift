//
//  DictionarySearchResult.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import Foundation
import RealmSwift

/// A Realm model for storing references to `DictionaryEntry` results that are yielded from dictionary database searches.
class DictionarySearchResult: Object {
    
    /// Identifier for database purposes.
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// Original search term used to make the result.
    @Persisted(indexed: true) var searchTerm: String
    
    /// The best length found for the search term used for highlighting the selected word.
    @Persisted var bestLength: Int
    
    /// The current scroll position of the result in dictionary history.
    @Persisted var scrollPosition: Int
    
    /// List of heading IDs by sorting order.
    @Persisted var headingIds: List<Int>
    
    /// A single result may have multiple headings in the result, which in turn contain multiple dictionary entries.
    /// Pending implementation: `DictionaryHeading` model.
    @Persisted(originProperty: "searchResults") var headings: LinkingObjects<DictionaryHeading>
    
    /// Convenience initializer.
    convenience init(searchTerm: String, bestLength: Int = 0, scrollPosition: Int = 0, headingIds: [Int] = []) {
        self.init()
        self.searchTerm = searchTerm
        self.bestLength = bestLength
        self.scrollPosition = scrollPosition
        self.headingIds.append(objectsIn: headingIds)
    }
}

