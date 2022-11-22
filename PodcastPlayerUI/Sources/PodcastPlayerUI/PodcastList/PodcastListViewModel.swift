//
//  PodcastListViewModel.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import SwiftUI
import Combine
import PodcastPlayer

public class PodcastListViewModel: ObservableObject {
    internal let podcastPlayer: PodcastPlayer
    private let podcastLoader: PodcastLoader
    private var bag = Set<AnyCancellable>()
    
    @Published public var podcasts: [Podcast] = []
    @Published public var isLoadingPodcast: Bool = false
    @Published public var showMiniPlayer: Bool = false
    
    public init(podcastLoader: PodcastLoader, podcastPlayer: PodcastPlayer) {
        self.podcastLoader = podcastLoader
        self.podcastPlayer = podcastPlayer
    }
    
    func loadPodcast() {
        isLoadingPodcast = true
        podcastLoader.loadPodcasts().sink { [unowned self] podcasts in
            self.podcasts = podcasts
            self.isLoadingPodcast = false
        }.store(in: &bag)
    }
    deinit {
        podcastPlayer.stop()
    }
    
}
