//
//  PlayerStatus.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation

public enum PlayerStatus {
    case loading
    case playing
    case paused
    case failed(String)
}
