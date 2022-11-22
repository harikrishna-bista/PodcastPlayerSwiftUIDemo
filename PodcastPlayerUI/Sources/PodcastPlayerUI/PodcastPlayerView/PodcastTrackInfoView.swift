//
//  PodcastTrackInfoView.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI

public struct PodcastTrackInfoView: View {
    @Binding public var trackName: String
    @Binding public var artistName: String
    
    public var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(trackName)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
            Text(artistName)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.accentColor)
        }
    }
}
