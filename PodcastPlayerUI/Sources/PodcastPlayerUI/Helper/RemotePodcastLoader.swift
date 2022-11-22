//
//  RemotePodcastLoader.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import Combine

public class RemotePodcastLoader: PodcastLoader {
    public func loadPodcasts() -> AnyPublisher<[Podcast], Never> {
        return Future<[Podcast], Never> { promise in
            
        }.eraseToAnyPublisher()
    }
}
