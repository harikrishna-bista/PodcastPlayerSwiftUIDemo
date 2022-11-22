//
//  TrackMeta.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public protocol TrackMeta {
    var trackLink: String { get }
    var type: String { get }
    var duration: Int { get }
}
