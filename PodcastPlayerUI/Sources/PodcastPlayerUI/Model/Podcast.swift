//
//  Podcast.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import PodcastPlayer


public class Podcast: PlayList, Decodable, Hashable {
    public static func == (lhs: Podcast, rhs: Podcast) -> Bool {
        lhs.playlistName == rhs.playlistName
    }
    
    public init(artWorkUrl: String = "https://www.freepik.com/download-file/16618745", playlistName: String = "The Atlantic", artistName: String = "The Atlantic", description: String = "Hello there", tracks: [Track] = [PodcastTrack()], feedURL: String = "") {
        self.artWorkUrl = artWorkUrl
        self.playlistName = playlistName
        self.artistName = artistName
        self.description = description
        self.tracks = tracks
        self.feedURL = feedURL
    }
   
    public func hash(into hasher: inout Hasher) {
        hasher.combine(playlistName)
    }
    
    public var artWorkUrl: String
    
    public var playlistName: String
    
    public var artistName: String
    
    public var description: String
    
    public var tracks: [Track]
    
    public var feedURL: String
    
    enum CodingKeys: String, CodingKey {
        case artistName, collectionName, feedUrl, artworkUrl600, tracks, description
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.artWorkUrl = try container.decode(String.self, forKey: .artworkUrl600)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.playlistName = try container.decode(String.self, forKey: .collectionName)
        self.feedURL = try container.decode(String.self, forKey: .feedUrl)
        self.tracks = try container.decodeIfPresent([PodcastTrack].self, forKey: .tracks) ?? []
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
}



