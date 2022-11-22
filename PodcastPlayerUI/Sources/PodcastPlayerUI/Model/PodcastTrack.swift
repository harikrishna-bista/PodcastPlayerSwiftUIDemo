//
//  PodcastTrack.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import PodcastPlayer

public class PodcastTrack: Track, Decodable {
    
    public init(title: String = "How To Season 3: When Expectations Don’t Meet Reality", description: String = "Hello", thumbnail: String? = nil, pubDate: Date = Date(), author: String = "The Atlantic", meta: TrackMeta = PodcastTrackMeta()) {
        self.title = title
        self.pubDate = pubDate
        self.thumbnail = thumbnail
        self.author = author
        self.meta = meta
        self.description = description
    }
    
    public var title: String
    
    public var description: String
    
    public var thumbnail: String?
   
    public var pubDate: Date
    
    public var author: String
    
    public var meta: TrackMeta
    
    enum CodingKeys: String, CodingKey {
        case title, pubDate, author, enclosure,  description, thumbnail
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.meta = try container.decode(PodcastTrackMeta.self, forKey: .enclosure)
        self.description = try container.decode(String.self, forKey: .description)
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail)
        
        let dateString = try container.decode(String.self, forKey: .pubDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:dd"
        self.pubDate = dateFormatter.date(from: dateString) ?? Date()
    }
    
}
