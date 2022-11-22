//
//  PodcastThumbnailView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI

public struct PodcastThumbnailView: View {
    @Binding public var imageSource: ImageSource?
    @Binding public var isPlaying: Bool
    
    public var body: some View {
        ThumbnailView(imageSource: imageSource)
            .equatable()
            .cornerRadius(10)
            .padding(isPlaying ? .zero : 35)
            .animation(.linear(duration: 0.1), value: isPlaying)

    }
}

