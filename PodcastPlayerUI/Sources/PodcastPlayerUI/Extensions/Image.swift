//
//  Image.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 17/11/22.
//

import SwiftUI

extension Image {
    static var playFilled: Image { Image(systemName: IconName.playFill.rawValue) }
    static var pauseFilled: Image { Image(systemName: IconName.pauseFill.rawValue) }
    
    static var forward10: Image { Image(systemName: IconName.forward10.rawValue) }
    static var backward10: Image { Image(systemName: IconName.backward10.rawValue) }
    
    static var forwardFilled: Image { Image(systemName: IconName.forwardFill.rawValue) }
    static var backwardFilled: Image { Image(systemName: IconName.backwardFill.rawValue) }
}
