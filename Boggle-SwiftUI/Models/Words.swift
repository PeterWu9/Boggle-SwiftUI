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
    static func load(filter predicate: @escaping (String) -> Bool) async throws -> PrefixTree<String> {
        try await Task<PrefixTree<String>, Swift.Error>(priority: .high) {
            guard let json = Bundle.main.url(forResource: "words" as String, withExtension: "json") else {
                throw Error.invalidURL
            }
            let words = try JSONDecoder().decode([String].self, from: try Data(contentsOf: json))
            
            let tree = PrefixTree(elements: words.filter(predicate))
            // Encode tree into data
            let data = try JSONEncoder().encode(tree)
            // TODO:  Why do you need to create application support directory?  
            // create directory
            let directoryURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let fileURL = directoryURL.appendingPathComponent("dictionary")
            // TODO:  Why doesn't this work (will first change target to 16.0)?
            // app will crash - file url not found
            // let url = URL.applicationSupportDirectory.appending(path: "dictionary")
            // Save data to directory
            try data.write(to: fileURL)
            
            return tree
        }.value
    }
}
