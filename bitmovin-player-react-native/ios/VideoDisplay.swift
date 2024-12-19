//
//  VideoDisplay.swift
//  RNBitmovinPlayer
//
//  Created by Josh Reed on 10/7/24.
//

import Foundation
import Combine
import GoogleInteractiveMediaAds
import BitmovinPlayer

public class VideoDisplay : NSObject, IMAVideoDisplay {
    public var delegate: (any IMAVideoDisplayDelegate)?
    public var player: Player
    
    private var cancellables: [AnyCancellable] = []
    
    public init(bitmovinPlayer: Player, playerDelegate: IMAVideoDisplayDelegate) {
        delegate = playerDelegate
        player = bitmovinPlayer
        super.init()
        
        player.events.on(PlayerEvent.self)
            .sink { event in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .store(in: &cancellables)

        player.events.on(SourceEvent.self)
            .sink { event in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
            .store(in: &cancellables)
//
//        player.events.on(ReadyEvent.self)
//            .sink { [weak self] _ in
//                guard let self else { return }
//                self.delegate?.videoDisplayDidLoad(self)
//                self.delegate?.videoDisplayDidStart(self)
//                self.delegate?.videoDisplayIsPlaybackReady?(self)
//            }
//            .store(in: &cancellables)
//
//        player.events.on(TimeChangedEvent.self)
//            .sink { [weak self] event in
//                guard let self else { return }
//
//                self.delegate?.videoDisplay(
//                    self,
//                    didProgressWithMediaTime: player.currentTime(.absoluteTime),
//                    totalTime: player.isLive ? 0 : player.duration
//                )
//            }
//            .store(in: &cancellables)
//
//        player.events.on(PlaybackFinishedEvent.self)
//            .sink { [weak self] _ in
//                guard let self else { return }
//                self.delegate?.videoDisplayDidComplete(self)
//            }
//            .store(in: &cancellables)
//
//        player.events.on(StallStartedEvent.self)
//            .sink { [weak self] _ in
//                guard let self else { return }
//                self.delegate?.videoDisplayDidStartBuffering?(self)
//            }
//            .store(in: &cancellables)
//
//        player.events.on(StallEndedEvent.self)
//            .sink { [weak self] _ in
//                guard let self else { return }
//                self.delegate?.videoDisplayIsPlaybackReady?(self)
//            }
//            .store(in: &cancellables)
//
//        Publishers.Merge(
//            player.events.on(SourceErrorEvent.self)
//                .map { NSError(domain: "BitmovinPlayerSourceError", code: $0.code.rawValue, userInfo: [NSLocalizedDescriptionKey: $0.message]) },
//            player.events.on(PlayerErrorEvent.self)
//                .map { NSError(domain: "BitmovinPlayerPlayerError", code: $0.code.rawValue, userInfo: [NSLocalizedDescriptionKey: $0.message]) }
//        )
//        .sink { [weak self] error in
//            guard let self else { return }
//            self.delegate?.videoDisplay(self, didReceiveError: error)
//        }
//        .store(in: &cancellables)
//
        player.events.on(MetadataEvent.self)
            .sink { [weak self] event in
                guard let self else { return }
                guard event.metadataType == .ID3 else {
                    return
                }

                let metadata: [String: String] = event.metadata
                    .entries
                    .compactMap { $0 as? AVMetadataItem }
                    .reduce(into: [:]) { partialResult, entry in
                        guard let key = entry.key,
                              let value = entry.value else {
                            return
                        }
                        partialResult["\(key)"] = "\(value)"
                    }

                self.delegate?.videoDisplay(self, didReceiveTimedMetadata: metadata)
            }
            .store(in: &cancellables)
    }
    
    public var volume: Float {
        get {
            Float(player.volume) / 100.0
        }
        set {
            player.volume = Int(newValue * 100)
            delegate?.videoDisplay(self, volumeChangedTo: NSNumber(value: newValue))
        }
    }
    
    public func loadStream(_ streamURL: URL, withSubtitles subtitles: [[String : String]]) {
        let source = SourceConfig(url: streamURL)!
        player.load(sourceConfig: source)
    }
    
    public func play() {
        player.play()
        delegate?.videoDisplayDidResume(self)
    }
    
    public func pause() {
        player.pause()
        delegate?.videoDisplayDidPause(self)
    }
    
    public func reset() {
        player.unload()
        
    }
    
    public func seekStream(toTime time: TimeInterval) {
        if player.isLive {
            player.timeShift = time
        } else {
            player.seek(time: time)
        }
    }
    
    public var currentMediaTime: TimeInterval {
        player.currentTime(.absoluteTime)
    }
    
    public var totalMediaTime: TimeInterval {
        player.isLive ? 0 : player.duration
    }
    
    public var bufferedMediaTime: TimeInterval {
        player.buffer.getLevel(.forwardDuration).level
    }
    
    public var isPlaying: Bool {
        player.isPlaying
    }
    
}


