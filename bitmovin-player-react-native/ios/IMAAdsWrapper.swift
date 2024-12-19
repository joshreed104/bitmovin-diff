//
//  IMAAdsWrapper.swift
//  RNBitmovinPlayer
//
//  Created by Josh Reed on 12/9/24.
//

import Foundation
import BitmovinPlayer
import GoogleInteractiveMediaAds

@objc (IMAAdsWrapper)
public class IMAAdsWrapper: NSObject, IMAStreamManagerDelegate, IMAAdsLoaderDelegate {
    
    
    private var adsLoader: IMAAdsLoader?
    private var playerModule: PlayerModule?
    public var adContainerView: UIView?
    public var playerViewController: UIViewController?
    private var assetKey: String?
    private var backupStreamURLString: String?
    private var videoDisplay: IMAVideoDisplay?
    private var streamManager: IMAStreamManager?
    private var adBreakActive: Bool?
    
    public func setPlayerModule(player: PlayerModule) {
        self.playerModule = player;
    }
    
    public func setAdContainerView(adContainer: UIView) {
        self.adContainerView = adContainer;
    }
    
    public func setPlayerViewController(playerViewController: UIViewController) {
        self.playerViewController = playerViewController;
    }
    
    public func setAssetKey(assetId: String) {
        self.assetKey = assetId;
    }
    
    public func setBackupStreamURLString(backupStreamUrl: String) {
        self.backupStreamURLString = backupStreamUrl;
    }
    
    public func setVideoDisplay(videoDisplay: IMAVideoDisplay) {
        self.videoDisplay = videoDisplay;
    }
    
    public func setupAdsLoader() -> Void {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader?.delegate = self;
    }
    
    public func requestStream(nativePlayer: Player) -> Void {
        createVideoDisplay(player: nativePlayer)
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adContainerView!, viewController: playerViewController)
        if (assetKey == nil) {
            loadBackupStream();
            return
        }
        let request = IMALiveStreamRequest(assetKey: assetKey!, adDisplayContainer: adDisplayContainer, videoDisplay: videoDisplay!, userContext: nil)
        adsLoader?.requestStream(with: request)
    }
    
    private func createVideoDisplay(player: Player) {
        let videoDisplayDelegate = VideoDisplayDelegate()
        self.videoDisplay = VideoDisplay(bitmovinPlayer: player, playerDelegate: videoDisplayDelegate)
    }
    
    public func loadBackupStream() -> Void {
        if (videoDisplay != nil && backupStreamURLString != nil) {
            print("[Bitmovin IMA Flow]: Loading backup stream")
            let streamURL = URL(string: backupStreamURLString!)
            videoDisplay!.loadStream(streamURL!, withSubtitles: [])
        } else {
            return;
        }
    }
    
    // adsLoader success
    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        streamManager = adsLoadedData.streamManager!
        streamManager!.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings();
        adsRenderingSettings.uiElements = [NSNumber(value: IMAUiElementType.elements_COUNTDOWN.rawValue), NSNumber(value: IMAUiElementType.elements_AD_ATTRIBUTION.rawValue)]
        streamManager!.initialize(with: adsRenderingSettings)
    }
    
    // adsLoader failure
    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: \(String(describing: adErrorData.adError.message))")
        loadBackupStream();
    }

    public func streamManager(_ streamManager: IMAStreamManager, didReceive event: IMAAdEvent) {
        print("StreamManager event \(event.typeString).")
        switch event.type {
//                        case IMAAdEventType.STREAM_STARTED:
//                          self.startMediaSession()
        case IMAAdEventType.STARTED:
            print("ad event started")
            // Log extended data.
            if let ad = event.ad {
                let extendedAdPodInfo = String(
                    format: "Showing ad %zd/%zd, bumper: %@, title: %@, "
                    + "description: %@, contentType:%@, pod index: %zd, "
                    + "time offset: %lf, max duration: %lf.",
                    ad.adPodInfo.adPosition,
                    ad.adPodInfo.totalAds,
                    ad.adPodInfo.isBumper ? "YES" : "NO",
                    ad.adTitle,
                    ad.adDescription,
                    ad.contentType,
                    ad.adPodInfo.podIndex,
                    ad.adPodInfo.timeOffset,
                    ad.adPodInfo.maxDuration)
                
                print("\(extendedAdPodInfo)")
            }
            break
        case IMAAdEventType.AD_BREAK_STARTED:
            print("ad break started")
            // Trigger an update to send focus to the ad display container.
            adBreakActive = true
            break
        case IMAAdEventType.AD_BREAK_ENDED:
            // Trigger an update to send focus to the content player.
            print("ad break ended")
            adBreakActive = false
            break
        case IMAAdEventType.ICON_FALLBACK_IMAGE_CLOSED:
            // Resume playback after the user has closed the dialog.
            print("ad image close")
            self.videoDisplay!.play()
            break
        case IMAAdEventType.TAPPED:
            if (videoDisplay?.isPlaying == true) {
                videoDisplay?.pause()
            } else {
                videoDisplay?.play()
            }
        default:
            print("unknown event received")
            break
        }

    }
    
    public func streamManager(_ streamManager: IMAStreamManager, didReceive error: IMAAdError) {
        print("StreamManager error: \(error.message ?? "Unknown Error")")
    }
    
}


