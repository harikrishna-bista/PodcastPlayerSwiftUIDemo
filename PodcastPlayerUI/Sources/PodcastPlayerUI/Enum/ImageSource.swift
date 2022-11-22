//
//  ImageSource.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public enum ImageSource {
    case image(String)
    case url(URL)
}

extension ImageSource: Equatable {
    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        switch (lhs, rhs) {
        case (.image(let str1), .image(let str2)):
            return str1 == str2
        case (.url(let url1), .url(let url2)):
            return url1.absoluteString == url2.absoluteString
        default:
            return false
        }
    }
}
