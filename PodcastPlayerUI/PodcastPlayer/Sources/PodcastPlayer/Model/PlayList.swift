//
//  PlayList.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public protocol PlayList {
    var artWorkUrl: String { get }
    var playlistName: String { get }
    var artistName: String { get }
    var description: String { get }
    var tracks: [Track] { get }
}
