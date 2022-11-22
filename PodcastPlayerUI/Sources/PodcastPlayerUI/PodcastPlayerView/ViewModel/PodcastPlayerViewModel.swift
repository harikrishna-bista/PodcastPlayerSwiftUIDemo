//
//  PodcastPlayerViewModel.swift
//  PodcastPlayerSwiftUI
//
//  Created by HariKrishnaBista on 15/11/22.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import PodcastPlayer

public class PodcastPlayerViewModel: ObservableObject {
    
    @Published public var currentTimeInfo: String = CMTime.zero.positionalTime
    @Published public var durationTimeInfo: String = CMTime.zero.positionalTime
    @Published public var trackName: String = ""
    @Published public var artistName: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isPlaying: Bool = false
    @Published public var thumbnailSource: ImageSource?
    @Published public var playbackProgressValue: Float = .zero
    @Published public var currentVolume: Float = .zero {
        didSet {
            if oldValue != currentVolume {
                podcastPlayer.setVolume(currentVolume)
            }
        }
    }
    
    @Published public var manualPlaybackSeekValue: Float = .zero {
        didSet {
            podcastPlayer.seekToRatio(manualPlaybackSeekValue)
        }
    }
    
    private let podcastPlayer: Player
    private let playList: PlayList
    @Binding private var index: Int
    private var bag: Set<AnyCancellable>
    
    public init(podcastPlayer: Player, playlist: PlayList, index: Binding<Int>) {
        self.podcastPlayer = podcastPlayer
        self.playList = playlist
        self._index = index
        self.bag = Set<AnyCancellable>()
        self.observePlayerEvents()
    }
    
    public init(podcastPlayer: Player) {
        self.podcastPlayer = podcastPlayer
        var index: Int = 0
        if let playList = podcastPlayer.currentPlayList.value {
            self.playList = playList
        } else {
            self.playList = Podcast()
            fatalError("Missing playlist in the player")
        }
        
        if let track = podcastPlayer.currentTrack.value {
            if let trackIndex = playList.tracks.firstIndex(where: { $0.title == track.title }) {
                index = trackIndex
            }
        } else {
            index = 0
            fatalError("Missing track in the player")
        }
        self._index = .constant(index)
        self.bag = Set<AnyCancellable>()
        self.observePlayerEvents()
    }
    
    private func observePlayerEvents() {
        observePlayerTimes()
        observePlayerStatus()
        observeTrackChanged()
        observeVolumeChanged()
    }
    
    private func observePlayerTimes() {
        Publishers.Zip(podcastPlayer.currentTime, podcastPlayer.durationTime).sink { [unowned self] currentTime, durationTime in
            self.currentTimeInfo = currentTime.positionalTime
            self.durationTimeInfo = durationTime.positionalTime
            self.playbackProgressValue = Float(currentTime.seconds / durationTime.seconds)
        }.store(in: &bag)
    }
    
    private func observePlayerStatus() {
        podcastPlayer.playerStatus.sink { [unowned self] status in
            guard let status = status else { return }
            switch status {
            case .loading:
                self.isLoading = true
            case .playing:
                self.isLoading = false
                self.isPlaying = true
            case .paused:
                self.isLoading = false
                self.isPlaying = false
            case .failed(let error):
                debugPrint(error)
            }
        }.store(in: &bag)
    }
    
    private func observeVolumeChanged() {
        podcastPlayer.volume.sink { [unowned self] volume in
            self.currentVolume = volume
        }.store(in: &bag)
    }
    
    private func observeTrackChanged() {
        podcastPlayer.currentTrack.sink { [unowned self] track in
            guard let track = track else {
                self.thumbnailSource = nil
                return
            }
            let str = track.thumbnail?.isEmpty == false ? track.thumbnail : playList.artWorkUrl
            if let url = URL(string: str ?? "") {
                self.thumbnailSource = .url(url)
            }
            self.trackName = track.title
            self.artistName = track.author
        }.store(in: &bag)
    }
    
    public func playThePlayList() {
        let newTrack = self.playList.tracks[index]
        let currentPlayingTrack = podcastPlayer.currentTrack.value
        guard currentPlayingTrack?.title != newTrack.title else {
            if !isPlaying {
                play()
            }
            return
        }
        podcastPlayer.seekToRatio(.zero)
        podcastPlayer.startPlaying(playList: playList, atIndex: index)
    }
    public func play() {
        podcastPlayer.play()
    }
    
    public func pause() {
        podcastPlayer.pause()
    }
    
    public func playNext() {
        podcastPlayer.playNext()
    }
    
    public func playPrevious() {
        podcastPlayer.playPrevious()
    }
    
    public func seekToRatio(ratio: Float) {
        podcastPlayer.seekToRatio(ratio)
    }
    
    public func skipBackward(seconds: Double) {
        podcastPlayer.skipBackward(seconds: seconds)
    }
    
    public func skipForward(seconds: Double) {
        podcastPlayer.skipForward(seconds: seconds)
    }
    
    public func buttonTapHandler() -> ((PodcastPlayerButtonTapEvent) -> Void) {
        return { [unowned self] event in
            switch event {
            case .skipBackward(let seconds):
                self.skipBackward(seconds: seconds)
            case .previous:
                self.playPrevious()
            case .play:
                self.play()
            case .pause:
                self.pause()
            case .next:
                self.playNext()
            case .skipForward(let seconds):
                self.skipForward(seconds: seconds)
            }
        }
    }
}



/// Extension to convert CMTime to textual information
extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours: Int { return Int(seconds / 3600) }
    var minute: Int { return Int(seconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(seconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        guard self != .zero else { return  "-:-" }
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
