//
//  MiniPodcastPlayerView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI
import PodcastPlayer

public struct MiniPodcastPlayerView: View {
    @ObservedObject private var viewModel: PodcastPlayerViewModel
    
    private let height: CGFloat = 60
    
    public init(viewModel: PodcastPlayerViewModel) {
        self.viewModel = viewModel
    }
    public var body: some View {
        ZStack {
            Color.white
                .shadow(radius: 1)
            HStack {
                ThumbnailView(imageSource: viewModel.thumbnailSource)
                    .frame(width: 50)
                    .cornerRadius(2)
                Text(viewModel.trackName)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 15) {
                    playPauseButton
                    skipButton
                }
                .frame(width: 75)
            }
            .padding(8)
        }
        .frame(height: height)
    }
    
    @ViewBuilder
    private var skipButton: some View {
        button(event: .skipForward(10), image: .forward10)
    }
    
    
    @ViewBuilder
    private var playPauseButton: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.isPlaying {
            button(event: .pause, image: .pauseFilled)
        } else {
            button(event: .play, image: .playFilled)
        }
    }
    
    @ViewBuilder
    private func button(event: PodcastPlayerButtonTapEvent, image: Image) -> some View {
        Button {
            let handler = viewModel.buttonTapHandler()
            handler(event)
        } label: {
            image
                .font(.title2)
        }
        
    }
    
}

struct MiniPodcastPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PodcastPlayerViewModel(podcastPlayer: PodcastPlayer.shared, playlist: Podcast(), index: .constant(0))
        MiniPodcastPlayerView(viewModel: viewModel)
        .onAppear {
            viewModel.playThePlayList()
        }
    }
}

