//
//  PodcastEpisodesView.swift
//  PodcastPlayerSwiftUI
//
//  Created by ebpearls on 16/11/2022.
//

import SwiftUI
import PodcastPlayer

public struct PodcastDetailView: View {
    @ObservedObject private var viewModel: PodcastListViewModel
    
    @State private var playPodcast = false
    @State private var expandMiniPlayer = false
    @State private var onDismiss = false
    @State private var trackIndex: Int = 0
    
    private let podcast: Podcast
    
    public init(podcast: Podcast, viewModel: PodcastListViewModel) {
        self.podcast = podcast
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            List {
                descriptionSection
                episodesSection
            }
            .padding(.bottom, viewModel.showMiniPlayer ? 60 : 0)
        }
        .overlay(alignment: .bottom, content: {
            if viewModel.podcastPlayer.currentPlayList.value != nil || viewModel.showMiniPlayer {
                miniPodcastPlayerView
            }
        })
        .navigationTitle(podcast.artistName)
        .listStyle(.plain)
        .sheet(isPresented: $playPodcast) {
            viewModel.showMiniPlayer = true
        } content: {
            PodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: PodcastPlayer.shared, playlist: podcast, index: $trackIndex))
        }
        .sheet(isPresented: $expandMiniPlayer) {
            viewModel.showMiniPlayer = true
        } content: {
            PodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: PodcastPlayer.shared))
        }

    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading) {
            Group {
                if let url = URL(string: podcast.artWorkUrl) {
                    ThumbnailView(imageSource: .url(url))
                } else {
                    Color.secondary
                }
            }
            .frame(height: 150)
            Text(podcast.playlistName)
                .font(.system(size: 20, weight: .bold))
            HStack {
                Image.playFilled
                    .font(.system(size: 10))
                    .modifier(CircleBackground(padding: 5))
                Text("Play")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 15, weight: .regular))
            }
            .padding(.bottom, 5)
            .onTapGesture {
                playPodcast = true
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(podcast.artistName)
                    .font(.system(size: 14))
                Text(podcast.description)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }

        }
        .listRowSeparator(.hidden)
       
    }
    
    private var episodesSection: some View {
        Section {
            ForEach(Array(podcast.tracks.enumerated()), id: \.1.title) { index, track in
                let url = track.thumbnail?.isEmpty == false ? track.thumbnail : podcast.artWorkUrl
                PodcastEpisodeRow(imageURL: url, episodeDate: track.pubDate, episodeTitle: track.title, episodeDescription: track.description)
                    .onTapGesture {
                        trackIndex = index
                        playPodcast = true
                    }
                    .listRowSeparator(.hidden)
            }
        } header: {
            Text("Episodes")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
        }
    }
    
    private var miniPodcastPlayerView: some View {
        MiniPodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: viewModel.podcastPlayer))
            .background(.white)
            .onTapGesture {
                expandMiniPlayer = true
            }
    }
}




struct PodcastEpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PodcastListViewModel(podcastLoader: LocalPodcastLoader(), podcastPlayer: PodcastPlayer.shared)
        viewModel.loadPodcast()

        return PodcastDetailView(podcast: viewModel.podcasts[0], viewModel: viewModel)
            
    }
}



