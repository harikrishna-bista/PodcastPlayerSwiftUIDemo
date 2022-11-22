//
//  PodcastLoader.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import Combine

public protocol PodcastLoader {
    func loadPodcasts() -> AnyPublisher<[Podcast], Never>
}
