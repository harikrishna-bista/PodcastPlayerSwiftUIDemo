//
//  PodcastView.swift
//  PodcastPlayerDemo
//
//  Created by HariKrishnaBista on 21/11/22.
//

import Foundation
import PodcastPlayerUI
import SwiftUI
import PodcastPlayer

struct PodcastView: View {
    var body: some View {
        PodcastListView(viewModel:
                PodcastListViewModel(podcastLoader: LocalPodcastLoader(), podcastPlayer: PodcastPlayer.shared)
        )
    }
}

struct PodcastView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastView()
    }
}
