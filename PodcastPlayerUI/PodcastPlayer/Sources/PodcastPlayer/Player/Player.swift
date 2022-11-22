//
//  Player.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 18/11/22.
//

import Foundation
import Combine
import AVFoundation

public protocol Player {
    var currentTime: CurrentValueSubject<CMTime, Never> { get }
    var durationTime: CurrentValueSubject<CMTime, Never> { get }
    var playerStatus: CurrentValueSubject<PlayerStatus?, Never> { get }
    var currentPlayList: CurrentValueSubject<PlayList?, Never> { get }
    var currentTrack: CurrentValueSubject<Track?, Never> { get }
    var volume: CurrentValueSubject<Float, Never> { get }
    
    func startPlaying(playList: PlayList, atIndex index: Int)
    func play()
    func pause()
    func stop()
    func playNext()
    func playPrevious()
    func seekToRatio(_ ratio: Float)
    func skipForward(seconds: Double)
    func skipBackward(seconds: Double)
    func setVolume(_ volume: Float)
}
