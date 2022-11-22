//
//  PlayerSliderView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI

public struct PodcastPlayerSliderView: View {
    @Binding public var currentTimeInfo: String
    @Binding public var durationTimeInfo: String
    @Binding public var sliderValue: Float
    public var onEditingChanged: (Bool) -> Void
    
    public var body: some View {
        VStack(spacing: 5) {
            HStack {
                timeInfoText(currentTimeInfo)
                Spacer()
                timeInfoText(durationTimeInfo)
            }
            Slider(value: $sliderValue, onEditingChanged: onEditingChanged)
        }
    }
    
    @ViewBuilder
    private func timeInfoText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
    }
}
