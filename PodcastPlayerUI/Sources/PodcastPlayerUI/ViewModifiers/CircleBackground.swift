//
//  CircleBackground.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import SwiftUI

public struct CircleBackground: ViewModifier {
    public init(padding: CGFloat, _ color: Color = .accentColor) {
        self.padding = padding
        self.color = color
    }
    
    public var padding: CGFloat
    public var color: Color
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .containerShape(circleShape)
            .background(circleShape.fill(color))
            .foregroundColor(.white)
    }
    private var circleShape: Circle { Circle() }
}
