//
//  PodcastPlayerDemoApp.swift
//  PodcastPlayerDemo
//
//  Created by HariKrishnaBista on 21/11/22.
//

import SwiftUI
import PodcastPlayerUI
import PodcastPlayer

@main
struct PodcastPlayerDemoApp: App {
    @State var isAppActive: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isAppActive {
                    PodcastView()
                } else {
                    SplashScreen(isAppActive: $isAppActive)
                }
            }
        }
    }
}

