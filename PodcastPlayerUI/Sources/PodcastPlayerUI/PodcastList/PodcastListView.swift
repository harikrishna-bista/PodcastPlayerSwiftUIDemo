//
//  PodcastListView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 16/11/22.
//

import SwiftUI
import Combine
import PodcastPlayer

public struct PodcastListView: View {
    @ObservedObject private var viewModel: PodcastListViewModel
    @State private var expandMiniPlayer = false
    
    public init(viewModel: PodcastListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                if viewModel.isLoadingPodcast {
                    ProgressView()
                } else if viewModel.podcasts.isEmpty {
                    Text("No podcasts")
                } else {
                    listView
                        .padding(.bottom, viewModel.showMiniPlayer ? 60 : 0)
                }
            }
            
        }
        .overlay(alignment: .bottom, content: {
            if viewModel.showMiniPlayer {
                miniPodcastPlayerView
            }
        })
        .navigationTitle("Podcasts")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $expandMiniPlayer) {
            viewModel.showMiniPlayer = true
        } content: {
            PodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: PodcastPlayer.shared))
        }
        .onAppear {
            if viewModel.podcasts.isEmpty {
                viewModel.loadPodcast()
            }
        }
    }
    
    private var listView: some View {
        List(viewModel.podcasts, id: \.playlistName) { podcast in
            NavigationLink {
                PodcastDetailView(podcast: podcast, viewModel: viewModel)
            } label: {
                PodcastListRow(podcast: podcast)
            }
        }
        .listStyle(.plain)
    }
    
    private var miniPodcastPlayerView: some View {
        MiniPodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: viewModel.podcastPlayer))
            .background(.white)
            .onTapGesture {
                expandMiniPlayer = true
            }
    }
}

struct PodcastListView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListView(viewModel: PodcastListViewModel(podcastLoader: LocalPodcastLoader(), podcastPlayer: PodcastPlayer.shared))
    }
}
