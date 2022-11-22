//
//  PodcastPlayer.swift
//  PodcastPlayerSwiftUI
//
//  Created by ebpearls on 11/11/2022.
//

import AVFoundation
import Combine
import MediaPlayer

public class PodcastPlayer: NSObject, Player {
    public static let shared = PodcastPlayer()
    
    /// Player to play from the url provided
    private var player: AVPlayer = AVPlayer(playerItem: nil)
    
    fileprivate var nowPlayingInfo : [String : Any] = [:]
    
    /// Context for observing playerItem
    private var playerItemContext = 0
    
    /// Observers for player
    private var playerObservers: [Any?] = []
 
    private var currentIndex: Int = -1
    
    public override init() {
        super.init()
        self.setupAudioSession()
        self.addPeriodicObserver()
        self.addStatusObserver()
        self.addVolumeChangeObserver()
        self.observeRemoteControlEvent()
        self.setupRemoteCommands()
    }
    
    /// Deinitialized
    deinit  {
        player.pause()
        debugPrint("deinit \(String(describing: self))")
        playerObservers = []
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        removeRemoteControlEventObserver()
    }
    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            DispatchQueue.main.async {
                self.volume.send(AVAudioSession.sharedInstance().outputVolume)
            }
            return
        }

        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .failed:
                guard let playerItem = object as? AVPlayerItem, let error = playerItem.error else { return }
                self.playerStatus.send(.failed(error.localizedDescription))
            default:
                break
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print("\n\t\tFailed to activate session:", sessionError)
        }
    }
    /// Method to provide the playerItem from preloaded cached or new initialized
    /// - Parameters:
    ///   - item: item to be used to initialize AVPlayerItem
    ///   - loadSync: boolean to indicate preload to handle synchronously or asynchronously
    /// - Returns: AVPlayerItem for playing
    private func getAVPlayerItem(url: URL, loadSync: Bool = false, queue:  DispatchQueue = .main, completion: @escaping (AVPlayerItem) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let asset = AVAsset(url: url)
            let keys = ["playable",
                        "hasProtectedContent", "duration"]
            var playerItem: AVPlayerItem!
            
            if loadSync {
                playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: keys)
            } else {
                asset.loadValuesAsynchronously(forKeys: keys, completionHandler: nil)
                playerItem = AVPlayerItem(asset: asset)
            }
            queue.async {
                playerItem.addObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.status),
                                           options: [.old, .new],
                                       context: &self.playerItemContext)
                NotificationCenter.default.addObserver(self, selector: #selector(self.currentItemFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                completion(playerItem)
            }
        }
    }
    
    /// Time observer
    private func addPeriodicObserver() {

        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
   
        let mainQueue = DispatchQueue.main
    
        let periodicObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let self = self, let duration = self.player.currentItem?.duration else { return }
            guard duration.seconds.isFinite && !duration.seconds.isNaN else { return }
            self.currentTime.send(time)
            self.durationTime.send(duration)
            self.updateNowPlayingInfo(playerItem: self.player.currentItem)
        }
        playerObservers.append(periodicObserver)
    }
    
    private func addVolumeChangeObserver() {
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", context: nil)
    }
    /// Player status observer
    private func addStatusObserver() {
        let timeControlObserver = self.player.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            switch player.timeControlStatus {
            case .playing:
                self.playerStatus.send(.playing)
            case .paused:
                self.playerStatus.send(.paused)
                self.updateNowPlayingInfo(playerItem: self.player.currentItem)
            case .waitingToPlayAtSpecifiedRate:
                self.playerStatus.send(.loading)
            default:
                break
            }
        }
        playerObservers.append(timeControlObserver)
    }
    
    /// Handle when current item finishes playing
    @objc private func currentItemFinishedPlaying() {
        playNext()
    }
    
    @objc private func volumeChanged() {
        self.volume.send(AVAudioSession.sharedInstance().outputVolume)
    }
    
    private func seekToTimeInterval(_ time: TimeInterval) {
        let time = CMTimeMakeWithSeconds(time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Jump through current playing item track position
    /// - Parameter time: TimeInterval
    private func skipTime(time: TimeInterval) {
        let current = player.currentTime()
        let currentSeconds = CMTimeGetSeconds(current)
        let value = currentSeconds + time
        let time = CMTimeMakeWithSeconds(value, preferredTimescale: CMTimeScale(USEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func getTrack(atIndex index: Int) -> Track? {
        guard let currentPlaylist = currentPlayList.value else { return nil }
        let tracks = currentPlaylist.tracks
        guard (0..<tracks.count).contains(index) else {
            seekToRatio(.zero) // reload
            return nil
        }
        let track = tracks[index]
        guard URL(string: track.meta.trackLink) != nil else { return nil }
        currentIndex = index
        return track
    }
    
    private func playTrack(_ track: Track?) {
        guard let track = track, let url = URL(string: track.meta.trackLink) else {
            return
        }
        currentTrack.send(track)
        updateNowPlayingArtwork()
        getAVPlayerItem(url: url) { [weak self] currentPlayerItem in
            guard let self = self else { return }
            self.player.replaceCurrentItem(with: currentPlayerItem)
            self.volume.send(AVAudioSession.sharedInstance().outputVolume)
            self.play()
        }
    }
   
   // MARK: - Player
    public var currentTime: CurrentValueSubject<CMTime, Never> = CurrentValueSubject(.zero)
    
    public var playerStatus: CurrentValueSubject<PlayerStatus?, Never> = CurrentValueSubject(nil)
    
    public var durationTime: CurrentValueSubject<CMTime, Never> = CurrentValueSubject(.zero)
    
    public var currentPlayList: CurrentValueSubject<PlayList?, Never> = CurrentValueSubject(nil)
    
    public var currentTrack: CurrentValueSubject<Track?, Never> = CurrentValueSubject(nil)
    
    public var volume: CurrentValueSubject<Float, Never> = CurrentValueSubject(50)
    
    public func startPlaying(playList: PlayList, atIndex index: Int) {
        currentPlayList.send(playList)
        playTrack(getTrack(atIndex: index))
    }
    
    public func play() {
        guard player.currentItem != nil else { return }
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func stop() {
        player.replaceCurrentItem(with: nil)
        currentPlayList.send(nil)
        currentTrack.send(nil)
    }
    
    public func playNext() {
        playTrack(getTrack(atIndex: currentIndex + 1))
    }
    
    public func playPrevious() {
        playTrack(getTrack(atIndex: currentIndex - 1))
    }
    
    public func seekToRatio(_ ratio: Float) {
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(ratio) * totalSeconds
        seekToTimeInterval(value)
    }
    
    public func skipForward(seconds: Double) {
        skipTime(time: +seconds)
    }
    
    public func skipBackward(seconds: Double) {
        skipTime(time: -seconds)
    }
    
    public func setVolume(_ volume: Float) {
       
    }
}

// MARK: - Remote controls
extension PodcastPlayer {
    func observeRemoteControlEvent() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let skipTime = NSNumber(value: 10)
        MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [skipTime]
        MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [skipTime]
    }
    
    func removeRemoteControlEventObserver() {
        UIApplication.shared.endReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func updateNowPlayingInfo(playerItem: AVPlayerItem?) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack.value?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentTrack.value?.author
        if let playerItem = playerItem {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: playerItem.duration.seconds)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: playerItem.currentTime().seconds)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNowPlayingArtwork() {
        guard let playList = currentPlayList.value, let track = currentTrack.value else {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
            return }
        let str = track.thumbnail?.isEmpty == false ? track.thumbnail : playList.artWorkUrl
        guard let url = URL(string: str ?? "") else { return }
          
        URLSession.shared.dataTask(with: url) { [weak self] imageData, _, _ in
            guard let imageData = imageData, let image = UIImage(data: imageData) else { return }
            self?.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: { size in
                return image
            })
        }.resume()
       
    }
    
    private func setupRemoteCommands() {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }
        
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }
    
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.seekToTimeInterval(event.positionTime)
            }
            return .success
        }
    }
}
