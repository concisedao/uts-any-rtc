import Foundation
import UIKit
import AVFoundation
import BytePlusRTC

class RtcEngineManager {

    static let shared = RtcEngineManager()

    private var rtcVideo: ByteRTCEngine?
    var isCapturingAudio: Bool = false
    var isCapturingVideo: Bool = false
    private var wasCapturingVideo: Bool = false
    private var currentCameraId: ByteRTCCameraID = .front

    private init() {
        rtcVideo = nil
    }

    // MARK: - Engine Lifecycle

    func createEngine(appId: String, delegate: ByteRTCEngineDelegate?) -> ByteRTCEngine? {
        guard rtcVideo == nil else { return nil }
        let config = ByteRTCEngineConfig(); config.appID = appId; rtcVideo = ByteRTCEngine.createRTCEngine(config, delegate: delegate)
        return rtcVideo
    }

    func destroyEngine() {
        stopAudioCapture()
        stopVideoCapture()
        RtcRoomManager.shared.destroyAllRooms()
        ByteRTCEngine.destroyRTCEngine()
        rtcVideo = nil
        isCapturingAudio = false
        isCapturingVideo = false
        wasCapturingVideo = false
    }

    func getEngine() -> ByteRTCEngine? {
        return rtcVideo
    }

    func isInitialized() -> Bool {
        return rtcVideo != nil
    }

    // MARK: - Permission Check

    static func hasCameraPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            // Trigger permission dialog, return false for now
            // Next call will return .authorized after user grants
            AVCaptureDevice.requestAccess(for: .video) { _ in }
            return false
        }
        return status == .authorized
    }

    static func hasMicrophonePermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { _ in }
            return false
        }
        return status == .authorized
    }

    // MARK: - Audio

    func startAudioCapture() {
        rtcVideo?.startAudioCapture()
        isCapturingAudio = true
    }

    func stopAudioCapture() {
        rtcVideo?.stopAudioCapture()
        isCapturingAudio = false
    }

    func setDefaultAudioRoute(useSpeaker: Bool) {
        rtcVideo?.setDefaultAudioRoute(useSpeaker ? .speakerphone : .earpiece)
    }

    // MARK: - Video

    func startVideoCapture() {
        rtcVideo?.startVideoCapture()
        isCapturingVideo = true
    }

    func stopVideoCapture() {
        rtcVideo?.stopVideoCapture()
        isCapturingVideo = false
    }

    func switchCamera(_ cameraId: ByteRTCCameraID) {
        currentCameraId = cameraId
        rtcVideo?.switchCamera(cameraId)
    }

    func setLocalVideoCanvas(streamIndex: ByteRTCStreamIndex, canvas: ByteRTCVideoCanvas?) {
        rtcVideo?.setLocalVideoCanvas(streamIndex, withCanvas: canvas)
    }

    func setRemoteVideoCanvas(roomId: String, uid: String, streamIndex: ByteRTCStreamIndex, canvas: ByteRTCVideoCanvas?) {
        let streamKey = ByteRTCRemoteStreamKey()
        streamKey.userId = uid
        streamKey.roomId = roomId
        streamKey.streamIndex = streamIndex
        rtcVideo?.setRemoteVideoCanvas(streamKey, withCanvas: canvas)
    }

    func setVideoEncoderConfig(_ config: ByteRTCVideoEncoderConfig) {
        rtcVideo?.setVideoEncoderConfig(config)
    }

    // MARK: - Lifecycle

    func onAppPause() {
        if isCapturingVideo {
            wasCapturingVideo = true
            rtcVideo?.stopVideoCapture()
            isCapturingVideo = false
        }
    }

    func onAppResume() {
        if wasCapturingVideo {
            rtcVideo?.startVideoCapture()
            isCapturingVideo = true
            wasCapturingVideo = false
        }
    }

    // MARK: - View Creation

    func createVideoView() -> UIView {
        return UIView()
    }
}
