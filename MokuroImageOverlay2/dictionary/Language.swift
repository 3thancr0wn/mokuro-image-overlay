//
//  Language.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/09.
//

import Foundation
import RealmSwift

/// Defines common characteristics required for tuning locale and text segmentation behaviour for different languages.
class Language: Object {
    // MARK: - Properties
    
    @Persisted(primaryKey: true) var id: ObjectId // Primary key
    @Persisted var languageName: String
    @Persisted var languageCode: String
    @Persisted var threeLetterCode: String
    @Persisted var countryCode: String
    @Persisted var textDirection: String // Use "LTR" or "RTL" as values
    @Persisted var preferVerticalReading: Bool
    @Persisted var isSpaceDelimited: Bool
    @Persisted var textBaseline: String // Use "Alphabetic" or "Ideographic"
    @Persisted var helloWorld: String
    @Persisted var standardFormat: String // Placeholder for `DictionaryFormat`
    @Persisted var defaultFontFamily: String
    @Persisted var indexMaxDistance: Int? // Optional value
    
    // MARK: - Initialization Flag (Transient Property)
    private var _initialised: Bool = false
    
    // MARK: - Initializer
    convenience init(
        languageName: String,
        languageCode: String,
        threeLetterCode: String,
        countryCode: String,
        textDirection: String,
        preferVerticalReading: Bool,
        isSpaceDelimited: Bool,
        textBaseline: String,
        helloWorld: String,
        standardFormat: String,
        defaultFontFamily: String,
        indexMaxDistance: Int? = nil
    ) {
        self.init()
        self.languageName = languageName
        self.languageCode = languageCode
        self.threeLetterCode = threeLetterCode
        self.countryCode = countryCode
        self.textDirection = textDirection
        self.preferVerticalReading = preferVerticalReading
        self.isSpaceDelimited = isSpaceDelimited
        self.textBaseline = textBaseline
        self.helloWorld = helloWorld
        self.standardFormat = standardFormat
        self.defaultFontFamily = defaultFontFamily
        self.indexMaxDistance = indexMaxDistance
    }
    
    // MARK: - Methods
    
    /// Checks if the language has been initialized.
    func initialise() async {
        if !_initialised {
            await prepareResources()
            _initialised = true
        }
    }
    
    /// Returns the locale based on language and country codes.
    var locale: Locale {
        Locale(identifier: "\(languageCode)-\(countryCode)")
    }
    
    /// Prepares resources necessary for this language to function.
    func prepareResources() async {
        // Placeholder for future implementation.
    }
    
    /// Returns a list of sentences from a given text block.
    func getSentences(from text: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: ".{1,}?([。.?？!！\\n]+)", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        guard !matches.isEmpty else { return [text] }
        
        return matches.map {
            let range = Range($0.range, in: text)!
            return String(text[range])
        }
    }
    
    /// Extracts a word from the given text at a specific index.
    func wordFromIndex(text: String, index: Int) -> String {
        guard let maxDistance = indexMaxDistance, text.count > maxDistance * 2 else {
            return parseWords(from: text)[safe: index] ?? ""
        }
        
        let rangeStart = max(0, index - maxDistance)
        let rangeEnd = min(text.count - 1, index + maxDistance)
        let substring = String(text[rangeStart...rangeEnd])
        
        return wordFromIndex(text: substring, index: index - rangeStart)
    }
    
    /// Splits text into words based on language-specific rules.
    func parseWords(from text: String) -> [String] {
        // Placeholder for language-specific parsing logic.
        return text.split(separator: " ").map(String.init)
    }
    
    /// Extracts a search term from the text at the given index.
    func getSearchTermFromIndex(text: String, index: Int) -> String {
        if isSpaceDelimited {
            let words = parseWords(from: text.replacingOccurrences(of: "\n", with: " "))
            return words.dropFirst(index).joined(separator: " ")
        } else {
            return String(text.suffix(from: text.index(text.startIndex, offsetBy: index)))
        }
    }
    
    /// Calculates the starting index for a search term based on a clicked position in text.
    func getStartingIndex(text: String, index: Int) -> Int {
        if isSpaceDelimited {
            var buffer = 0
            for word in parseWords(from: text.replacingOccurrences(of: "\n", with: " ")) {
                buffer += word.count
                if buffer > index { return buffer - word.count }
            }
        }
        return index
    }
}
