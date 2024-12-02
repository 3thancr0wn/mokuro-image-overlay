//
//  MokuroFileHandler.swift
//  MokuroImageOverlay2
//
//  Created by ethan crown on 2024/12/02.
//

import Foundation

struct MokuroFileHandler {
    static func readMokuroFile(filePath: String) -> MokuroData? {
        do {
            let fileURL = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            
            // Adjust decoding strategy if needed
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(MokuroData.self, from: data)
        } catch {
            print("Error reading .mokuro file: \(error)")
            return nil
        }
    }
}
