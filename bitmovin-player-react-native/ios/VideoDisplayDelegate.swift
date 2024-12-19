//
//  VideoDisplayDelegate.swift
//  RNBitmovinPlayer
//
//  Created by Josh Reed on 10/7/24.
//

import Foundation
import GoogleInteractiveMediaAds

public class VideoDisplayDelegate : NSObject, IMAVideoDisplayDelegate {
    
    
    public func videoDisplayDidLoad(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplayDidStart(_ videoDisplay: any IMAVideoDisplay) {
        
    }
    
    public func videoDisplayDidPause(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplayDidResume(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplayDidComplete(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplayDidClick(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplay(_ videoDisplay: any IMAVideoDisplay, didReceiveError error: any Error) {
    }
    
    public func videoDisplayDidSkip(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplayDidShowSkip(_ videoDisplay: any IMAVideoDisplay) {
    }
    
    public func videoDisplay(_ videoDisplay: any IMAVideoDisplay, volumeChangedTo volume: NSNumber) {
    }
    
    public func videoDisplay(_ videoDisplay: any IMAVideoDisplay, didProgressWithMediaTime mediaTime: TimeInterval, totalTime duration: TimeInterval) {
    }
    
    public func videoDisplay(_ videoDisplay: any IMAVideoDisplay, didReceiveTimedMetadata metadata: [String : String]) {
    }
}

