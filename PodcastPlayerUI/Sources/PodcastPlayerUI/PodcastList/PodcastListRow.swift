//
//  PodcastListRow.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import SwiftUI

public struct PodcastListRow: View {
    public var podcast: Podcast
    
    public var body: some View {
        HStack(spacing: 10) {
            if let url = URL(string: podcast.artWorkUrl) {
                ThumbnailView(imageSource: .url(url))
                    .frame(width: 120)
            } else {
                Color.secondary
                    .frame(width: 100)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(podcast.playlistName)
                    .font(.system(size: 18, weight: .semibold))
                Text(podcast.artistName)
                    .font(.system(size: 16, weight: .regular))
                Text("\(podcast.tracks.count) Episodes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 120)
    }
}
