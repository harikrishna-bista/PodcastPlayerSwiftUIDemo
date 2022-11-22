//
//  PodcastEpisodeRow.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import SwiftUI

public struct PodcastEpisodeRow: View {
    public var imageURL: String?
    public var episodeDate: Date
    public var episodeTitle: String
    public var episodeDescription: String
    
    public var body: some View {
        HStack(spacing: 10) {
            if let url = URL(string: imageURL ?? "") {
                ThumbnailView(imageSource: .url(url))
                    .frame(width: 120)
            } else {
                Color.secondary
                    .frame(width: 100)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(episodeDate.formatted(.dateTime.day().month().year()))
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .regular))
                Text(episodeTitle)
                    .font(.system(size: 18, weight: .semibold))
                Text(episodeDescription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 120)
    }
}
