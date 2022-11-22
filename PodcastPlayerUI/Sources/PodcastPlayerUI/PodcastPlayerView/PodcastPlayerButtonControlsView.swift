//
//  PodcastPlayerButtonControlsView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI

public struct PodcastPlayerButtonControlsView: View {
    @Binding public var isLoading: Bool
    @Binding public var isPlaying: Bool
    public var buttonTapHandler: (PodcastPlayerButtonTapEvent) -> Void
    
    public var body: some View {
        HStack(spacing: 20) {
            skipBackwardButton
            previousButton
            playPauseButton
            nexButton
            skipForwardButton
        }
       .font(.system(size: 38))
       .padding()
    }
    
    private var skipBackwardButton: some View { button(event: .skipBackward(10), image: .backward10) }
    
    private var skipForwardButton: some View { button(event: .skipForward(10), image: .forward10) }
    
    private var previousButton: some View { button(event: .previous, image: .backwardFilled) }
    
    private var nexButton: some View { button(event: .next, image: .forwardFilled) }
    
    @ViewBuilder
    private var playPauseButton: some View {
        if isLoading {
           progressView
        } else if isPlaying {
            circleButton(event: .pause, image: .pauseFilled)
        } else {
            circleButton(event: .play, image: .playFilled)
        }
    }
    
    private var progressView: some View {
        ZStack {
            Color.clear
            ProgressView()
                .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                .tint(.accentColor)
        }
        .frame(height: 70)
    }
    
    @ViewBuilder
    private func circleButton(event: PodcastPlayerButtonTapEvent, image: Image) -> some View {
        Button {
            buttonTapHandler(event)
        } label: {
            image
                .foregroundColor(.white)
        }
        .modifier(CircleBackground(padding: 15))
    }
    
    @ViewBuilder
    private func button(event: PodcastPlayerButtonTapEvent, image: Image) -> some View {
        Button {
            buttonTapHandler(event)
        } label: {
            image
        }
    }
}

public enum PodcastPlayerButtonTapEvent {
    case skipBackward(Double)
    case previous
    case play
    case pause
    case next
    case skipForward(Double)
}
