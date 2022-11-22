//
//  LocalPodcastLoader.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation.NSBundle
import Combine

public class LocalPodcastLoader: PodcastLoader {
    public init() {}
    
    public func loadPodcasts() -> AnyPublisher<[Podcast], Never> {
        return Future<[Podcast], Never> { promise in
            let podcasts = Bundle.module.decode([Podcast].self, from: "Podcasts.json")
            promise(.success(podcasts))
        }.eraseToAnyPublisher()
    }
}

