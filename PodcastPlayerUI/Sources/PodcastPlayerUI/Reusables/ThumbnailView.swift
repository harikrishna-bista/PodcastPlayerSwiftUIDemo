//
//  ThumbnailView.swift
//  PodcastPlayerSwiftUI
//
//  Created by ebpearls on 08/11/2022.
//

import SwiftUI

public struct ThumbnailView: View, Equatable {
    var imageSource: ImageSource?
    
    public var body: some View {
        if let imageSource = imageSource {
            switch imageSource {
            case .image(let imageName):
                Image(imageName)
            case .url(let uRL):
                AsyncImage(url: uRL) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Color.gray
                        ProgressView().tint(.white)
                    }
                }
            }
        } else {
            Color.secondary
        }
    }
    
    public static func == (lhs: ThumbnailView, rhs: ThumbnailView) -> Bool {
        return lhs.imageSource == rhs.imageSource
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(imageSource: .url(URL(string: "https://www.freepik.com/download-file/16618745")!))
    }
}
