//
//  SplashScreen.swift
//  PodcastPlayerDemo
//
//  Created by HariKrishnaBista on 21/11/22.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @Binding var isAppActive: Bool
    
    var body: some View {
        Text("Podcast Player")
            .font(.title)
            .bold()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isAppActive = true
                }
            }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(isAppActive: .constant(false))
    }
}
