//
//  Bundle.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) in bundle.")
        }
        
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        return decoded
    }
    

}
