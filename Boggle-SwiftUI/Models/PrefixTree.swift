//
//  PrefixTree.swift
//  Boggle-SwiftUI
//
//  Created by Joshua Homann on 12/13/19.
//

import Foundation

final class PrefixTree<SomeCollection: RangeReplaceableCollection> where SomeCollection.Element: Hashable  {
    typealias Element = SomeCollection.Element
    typealias Node = PrefixTree<SomeCollection>
    private var children = [Element: PrefixTree]()
    private var isTerminal: Bool = false
    
    init(elements: [SomeCollection] = []) {
        self.children = [:]
        elements.forEach { self.insert($0) }
    }
    
    init(children: [Element: PrefixTree], isTerminal: Bool) {
        self.children = children
        self.isTerminal = isTerminal
    }
    
    func insert(_ collection: SomeCollection) {
        terminalNode(for: collection, shouldInsert: true)?.isTerminal = true
    }
    
    func contains(_ collection: SomeCollection) -> Bool {
        terminalNode(for: collection)?.isTerminal == true
    }
    
    func contains(prefix: SomeCollection) -> Bool {
        terminalNode(for: prefix) != nil
    }
    
    private func terminalNode(for path: SomeCollection, shouldInsert: Bool = false) -> Node? {
        path.reduce(into: self as Node?) { node, element in
            if shouldInsert {
                let child = node?.children[element, default: Self()]
                node?.children[element] = child
            }
            node = node?.children[element]
        }
    }
}

// MARK: Codable Conformance

// Attempt to make PrefixTree Codable if the Collections are codable
//extension PrefixTree: Codable where SomeCollection: Codable { }

// Attempt to make PrefixTree<String> Codable by converting characters to string
extension PrefixTree: Encodable where SomeCollection == String {
    enum CodingKeys: String, CodingKey {
        case children
        case isTerminal
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let newChildren = children.reduce(into: [String: Self]()) { accumulated, next in
            accumulated[String(next.key)] = next.value
        }
        try container.encode(isTerminal, forKey: .isTerminal)
        try container.encode(newChildren, forKey: .children)
    }
}

extension PrefixTree: Decodable where SomeCollection == String {
    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isTerminal = try container.decode(Bool.self, forKey: .isTerminal)
        let childrenKeyedByString = try container.decode([String: PrefixTree].self, forKey: .children)
        let children = childrenKeyedByString.reduce(into: [Character: PrefixTree]()) { accumulated, next in
            accumulated[Character(next.key)] = next.value
        }
        self.init(children: children, isTerminal: isTerminal)
    }
}
