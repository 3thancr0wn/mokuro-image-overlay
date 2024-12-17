//
//  LanguageUtils.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/09.
//

import Foundation
import RealmSwift

// Summary:
// - Classes `DictionaryHeading`, `RubyTextData`, and any dependencies like `KanaKit` are not implemented here and must be defined separately.

/// Extra methods for matching text with patterns.
extension NSRegularExpression {
    /// Splits a string into an array of strings based on matches while keeping delimiters.
    func allMatchesWithSep(text: String, start: Int = 0) -> [String] {
        var result: [String] = []
        let range = NSRange(location: start, length: text.utf16.count - start)
        let matches = self.matches(in: text, options: [], range: range)
        
        var lastEnd = start
        for match in matches {
            let matchStart = match.range.lowerBound
            let matchEnd = match.range.upperBound
            
            let leadingTextRange = text.index(text.startIndex, offsetBy: lastEnd)..<text.index(text.startIndex, offsetBy: matchStart)
            let matchTextRange = text.index(text.startIndex, offsetBy: matchStart)..<text.index(text.startIndex, offsetBy: matchEnd)
            
            result.append(String(text[leadingTextRange]))
            result.append(String(text[matchTextRange]))
            
            lastEnd = matchEnd
        }
        
        if lastEnd < text.utf16.count {
            let trailingTextRange = text.index(text.startIndex, offsetBy: lastEnd)..<text.endIndex
            result.append(String(text[trailingTextRange]))
        }
        
        return result
    }
}

/// Extra methods for String.
extension String {
    /// Splits the string using a regular expression, keeping delimiters.
    func splitWithDelim(pattern: NSRegularExpression) -> [String] {
        return pattern.allMatchesWithSep(text: self)
    }
}

/// A class utilized in the process of distributing Furigana.
class FuriganaDistributionGroup {
    /// The original text.
    var text: String
    /// The text converted to kana.
    var textNormalized: String?
    /// Whether or not this group pertains to kana.
    var isKana: Bool
    
    init(isKana: Bool, text: String, textNormalized: String? = nil) {
        self.isKana = isKana
        self.text = text
        self.textNormalized = textNormalized
    }
}

/// A class for general language utility functions.
class LanguageUtils {
    private static let hiraganaRange: ClosedRange<UInt32> = 0x3040...0x309F
    private static let katakanaRange: ClosedRange<UInt32> = 0x30A0...0x30FF
    private static let kanaRanges = [hiraganaRange, katakanaRange]
    
    private static let kanaKit = KanaKit() // Replace with equivalent Swift kana utility.
    private static var furiganaCache: [DictionaryHeading: [RubyTextData]] = [:]
    
    /// Check if a code point is in a given range.
    static func isCodePointInRange(_ codePoint: UInt32, range: ClosedRange<UInt32>) -> Bool {
        return range.contains(codePoint)
    }
    
    /// Check if a code point is within multiple ranges.
    static func isCodePointInRanges(_ codePoint: UInt32, ranges: [ClosedRange<UInt32>]) -> Bool {
        return ranges.contains { isCodePointInRange(codePoint, range: $0) }
    }
    
    /// Check if a code point is kana.
    static func isCodePointKana(_ codePoint: UInt32) -> Bool {
        return isCodePointInRanges(codePoint, ranges: kanaRanges)
    }
    
    /// Generate Furigana for a DictionaryHeading.
    static func distributeFurigana(for heading: DictionaryHeading) -> [RubyTextData] {
        if let cachedFurigana = furiganaCache[heading] {
            return cachedFurigana
        }
        
        let term = heading.term
        let reading = heading.reading
        
        if reading == term {
            return [RubyTextData(term: term)]
        }
        
        var groups: [FuriganaDistributionGroup] = []
        var groupPre: FuriganaDistributionGroup? = nil
        var isKanaPre: Bool? = nil
        
        for scalar in term.unicodeScalars {
            let character = String(scalar)
            let isKana = isCodePointKana(scalar.value)
            
            if isKanaPre == isKana {
                groupPre?.text += character
            } else {
                groupPre = FuriganaDistributionGroup(isKana: isKana, text: character)
                groups.append(groupPre!)
                isKanaPre = isKana
            }
        }
        
        for group in groups where group.isKana {
            group.textNormalized = kanaKit.toHiragana(group.text) // Replace with your kana conversion method.
        }
        
        let readingNormalized = kanaKit.toHiragana(reading)
        
        do {
            if let segments = try segmentizeFurigana(reading: reading, readingNormalized: readingNormalized, groups: groups, groupsStart: 0) {
                return segments
            }
        } catch {
            return [RubyTextData(term: term, ruby: reading)]
        }
        
        return [RubyTextData(term: term, ruby: reading)]
    }
    
    /// Segment Furigana.
    static func segmentizeFurigana(
        reading: String,
        readingNormalized: String,
        groups: [FuriganaDistributionGroup],
        groupsStart: Int
    ) throws -> [RubyTextData]? {
        let groupCount = groups.count - groupsStart
        
        if groupCount <= 0 {
            return reading.isEmpty ? [] : nil
        }
        
        let group = groups[groupsStart]
        
        if group.isKana {
            if let textNormalized = group.textNormalized,
               readingNormalized.starts(with: textNormalized) {
                
                let remainingSegments = try segmentizeFurigana(
                    reading: String(reading.dropFirst(group.text.count)),
                    readingNormalized: String(readingNormalized.dropFirst(group.text.count)),
                    groups: groups,
                    groupsStart: groupsStart + 1
                )
                
                if let segments = remainingSegments {
                    if reading.starts(with: group.text) {
                        return [RubyTextData(term: group.text)] + segments
                    } else {
                        return getFuriganaKanaSegments(text: group.text, reading: reading) + segments
                    }
                }
            }
            return nil
        } else {
            var result: [RubyTextData]? = nil
            
            for i in stride(from: reading.count, through: group.text.count, by: -1) {
                let readingPrefix = String(reading.prefix(i))
                let remainingSegments = try segmentizeFurigana(
                    reading: String(reading.dropFirst(i)),
                    readingNormalized: String(readingNormalized.dropFirst(i)),
                    groups: groups,
                    groupsStart: groupsStart + 1
                )
                
                if let segments = remainingSegments {
                    if result != nil {
                        return nil // Ambiguity detected.
                    }
                    result = [RubyTextData(term: group.text, ruby: readingPrefix)] + segments
                }
                
                if groupCount == 1 {
                    break
                }
            }
            
            return result
        }
    }
    
    /// Generate Furigana for kana.
    static func getFuriganaKanaSegments(text: String, reading: String) -> [RubyTextData] {
        var segments: [RubyTextData] = []
        var start = text.startIndex
        var isMatching = text.first == reading.first
        
        for (textChar, readingChar) in zip(text, reading) {
            let newState = textChar == readingChar
            if newState != isMatching {
                let segmentText = String(text[start..<text.index(after: textChar)])
                let ruby = isMatching ? "" : String(reading[start..<text.index(after: textChar)])
                segments.append(RubyTextData(term: segmentText, ruby: ruby))
                isMatching = newState
                start = text.index(after: textChar)
            }
        }
        
        segments.append(RubyTextData(term: String(text[start...]), ruby: isMatching ? "" : String(reading[start...])))
        
        return segments
    }
}

