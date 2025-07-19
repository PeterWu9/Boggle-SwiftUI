//
//  Words.swift
//  Boggle-SwiftUI
//
//  Created by Joshua Homann on 12/13/19.
//

import Foundation
import Combine
import UIKit

enum Words {
    enum Error: Swift.Error {
        case invalidURL
    }
    
    static func fileUrl() throws -> URL {
//        let directoryURL = try FileManager.default.url(
//            for: .applicationSupportDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: true
//        )
//        return directoryURL.appendingPathComponent("dictionary")
        // TODO:  Why doesn't this work (will first change target to 16.0)?
        // app will crash - file url not found
        let url = URL.applicationSupportDirectory
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url.appending(path: "dictionary")
    }
    
    static func load(filter predicate: @escaping (String) -> Bool) async throws -> PrefixTree<String> {
        try await Task<PrefixTree<String>, Swift.Error>(priority: .high) {
            // See if data can be load from disk
            do {
                let fileURL = try fileUrl()
                let data = try Data(contentsOf: fileURL)
                let tree = try JSONDecoder().decode(PrefixTree<String>.self, from: data)
                print(#function, "Tree loaded from disk")
                
                return tree
            } catch {
                print(#function, "Unable to load data from disk", error.localizedDescription)
            }
            
            // Data can't be loaded from disk.  Need to generate from bundle
            guard let json = Bundle.main.url(forResource: "words" as String, withExtension: "json") else {
                throw Error.invalidURL
            }
            let words = try JSONDecoder().decode([String].self, from: try Data(contentsOf: json))
            
            let tree = PrefixTree(elements: words.filter(predicate))
            
            // Try to save data into disk
            do {
                // Encode tree into data
                let data = try JSONEncoder().encode(tree)
                // Save data to directory
                try data.write(to: fileUrl())
                print(#function, "Data saved to disk")
            } catch {
                print(#function, "Unable to save data to disk", error.localizedDescription)
            }
            
            return tree
        }.value
    }
}
