//
//  DictioanryParams.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/08.
//

import Foundation

/// Structure for parameters required to prepare a dictionary.
struct PrepareDictionaryParams {
    /// The directory path where the dictionary is stored.
    var directoryPath: String
    
    /// The dictionary file name.
    var fileName: String
    
    /// The dictionary object being processed.
    var dictionary: Dictionary
    
    /// The format of the dictionary being processed.
    var dictionaryFormat: DictionaryFormat
    
    /// Closure to send status or results back to the caller.
    var send: (String) -> Void
}

/// Structure for updating the dictionary history.
struct UpdateDictionaryHistoryParams {
    /// The directory path where the history data is stored.
    var directoryPath: String
    
    /// The result ID of the dictionary search result to be updated.
    var resultId: Int
    
    /// The new scroll position to be stored in the history.
    var newPosition: Int
}

/// Structure for deleting dictionary data from the database.
struct DeleteDictionaryParams {
    /// The directory path where the dictionary data is stored.
    var directoryPath: String
    
    /// The ID of the dictionary to be deleted. Optional, as it might represent a single dictionary or all dictionaries.
    var dictionaryId: Int?
}

