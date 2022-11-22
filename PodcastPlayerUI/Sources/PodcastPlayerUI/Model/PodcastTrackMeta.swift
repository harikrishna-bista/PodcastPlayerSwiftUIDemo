//
//  PodcastTrackMeta.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import PodcastPlayer

public class PodcastTrackMeta: TrackMeta, Decodable {
    public init(trackLink: String = "https://www.thepodcastexchange.ca/s/AlanCross-Porter-v2.mp3", type: String = "", duration: Int = 0) {
        self.trackLink = trackLink
        self.type = type
        self.duration = duration
    }
    
    public var trackLink: String
    
    public var type: String
    
    public var duration: Int
    
    enum CodingKeys: String, CodingKey {
        case link, type, duration
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trackLink = try container.decode(String.self, forKey: .link)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        self.type = try container.decode(String.self, forKey: .type)
    }
}
