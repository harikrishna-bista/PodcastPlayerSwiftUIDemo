//
//  Track.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public protocol Track {
    var title: String { get }
    var thumbnail: String? { get }
    var description: String { get }
    var pubDate: Date { get }
    var author: String { get }
    var meta: TrackMeta { get }
}
