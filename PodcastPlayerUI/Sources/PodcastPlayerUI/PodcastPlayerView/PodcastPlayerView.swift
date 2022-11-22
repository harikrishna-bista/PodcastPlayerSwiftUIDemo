//
//  PodcastPlayerView.swift
//  PodcastPlayerSwiftUI
//
//  Created by ebpearls on 08/11/2022.
//

import SwiftUI
import AVFoundation
import Combine
import PodcastPlayer


public struct PodcastPlayerView: View {
    @ObservedObject private var viewModel: PodcastPlayerViewModel
    @State private var isPlaybackSliderTragging: Bool = false
    @State private var isVolumeSliderDragging: Bool = false
    
    public init(viewModel: PodcastPlayerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        fullPlayerView
            .padding(20)
            .onAppear {
                viewModel.playThePlayList()
            }
    }
}

// MARK: - Views
extension PodcastPlayerView {
    fileprivate var fullPlayerView: some View {
        VStack(spacing: 15) {
            dragToDismissIndicatorView
            thumbnailView
            trackInfo
            Spacer()
            playbackControlSlider
            Spacer()
            buttonControls
            Spacer()
        }
    }
    
    fileprivate var buttonControls: some View {
        PodcastPlayerButtonControlsView(isLoading: $viewModel.isLoading, isPlaying: $viewModel.isPlaying, buttonTapHandler: viewModel.buttonTapHandler())
    }
    
    fileprivate var dragToDismissIndicatorView: some View {
        Capsule()
            .frame(width: 40, height: 4)
            .foregroundColor(.gray)
            .opacity(0.5)
    }
    
    fileprivate var thumbnailView: some View {
        PodcastThumbnailView(imageSource: $viewModel.thumbnailSource, isPlaying: $viewModel.isPlaying)
    }
    
    
    fileprivate var playbackControlSlider: some View {
        let sliderValue = isPlaybackSliderTragging ? $viewModel.manualPlaybackSeekValue : $viewModel.playbackProgressValue
        return PodcastPlayerSliderView(currentTimeInfo: $viewModel.currentTimeInfo,
                                durationTimeInfo: $viewModel.durationTimeInfo,
                                sliderValue: sliderValue) { isDragging in
            isPlaybackSliderTragging = isDragging
        }
    }
    
    fileprivate var trackInfo: some View {
        PodcastTrackInfoView(trackName: $viewModel.trackName, artistName: $viewModel.artistName)
    }
    
}


struct PodcastPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastPlayerView(viewModel: PodcastPlayerViewModel(podcastPlayer: PodcastPlayer.shared, playlist: Podcast(), index: .constant(0)))
    }
}

