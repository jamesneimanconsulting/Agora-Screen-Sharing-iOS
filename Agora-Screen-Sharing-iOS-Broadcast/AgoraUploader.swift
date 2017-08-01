//
//  AgoraUploader.swift
//  Agora-Screen-Sharing-iOS-Broadcast
//
//  Created by GongYuhua on 2017/1/16.
//  Copyright © 2017年 Agora. All rights reserved.
//

import Foundation
import CoreMedia

class AgoraUploader {
    private static let sharedAgoraEngine: AgoraRtcEngineKit = {
        let kit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)!
        kit.setParameters("{\"che.hardware_encoding\":0}")
        kit.setChannelProfile(.channelProfile_LiveBroadcasting)
        kit.setExternalVideoSource(true, useTexture: true, pushMode: true)
        
        kit.enableVideo()
        kit.setVideoProfile(._VideoProfile_DEFAULT, swapWidthAndHeight: true)
        kit.setClientRole(.clientRole_Broadcaster, withKey: nil)
        
        AgoraAudioProcessing.registerAudioPreprocessing(kit)
        kit.setRecordingAudioFrameParametersWithSampleRate(44100, channel: 1, mode: .rawAudioFrame_OpMode_ReadWrite, samplesPerCall: 1024)
        kit.setParameters("{\"che.audio.external_device\":true}")
        return kit
    }()
    
    static func startBroadcast(to channel: String) {
        sharedAgoraEngine.joinChannel(byKey: nil, channelName: channel, info: nil, uid: 0, joinSuccess: nil)
    }
    
    static func sendVideoBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer)
             else {
            return
        }
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        let frame = AgoraVideoFrame()
        frame.format = 12
        frame.time = time
        frame.textureBuf = videoFrame
        sharedAgoraEngine.pushExternalVideoFrame(frame)
    }
    
    static func sendAudioAppBuffer(_ sampleBuffer: CMSampleBuffer) {
        AgoraAudioProcessing.pushAudioAppBuffer(sampleBuffer)
    }
    
    static func sendAudioMicBuffer(_ sampleBuffer: CMSampleBuffer) {
        AgoraAudioProcessing.pushAudioMicBuffer(sampleBuffer)
    }
    
    static func stopBroadcast() {
        sharedAgoraEngine.leaveChannel(nil)
    }
}
