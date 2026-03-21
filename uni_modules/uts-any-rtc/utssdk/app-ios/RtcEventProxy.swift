import Foundation
import BytePlusRTC

// MARK: - Engine Event Proxy

class RtcEventProxy: NSObject, ByteRTCEngineDelegate {

    var onWarningCallback: ((_ code: NSNumber, _ message: String) -> Void)?
    var onErrorCallback: ((_ code: NSNumber, _ message: String) -> Void)?
    var onLocalVideoStatsCallback: ((_ width: Int, _ height: Int, _ sentKBitrate: Int, _ frameRate: Int) -> Void)?
    var onLocalAudioStatsCallback: ((_ sentKBitrate: Int, _ audioLevel: Int) -> Void)?

    func rtcEngine(_ engine: ByteRTCEngine, onWarning code: ByteRTCWarningCode) {
        onWarningCallback?(NSNumber(value: code.rawValue), "Warning code: \(code.rawValue)")
    }

    func rtcEngine(_ engine: ByteRTCEngine, onError code: ByteRTCErrorCode) {
        onErrorCallback?(NSNumber(value: code.rawValue), "Error code: \(code.rawValue)")
    }

    func rtcEngine(_ engine: ByteRTCEngine, onLocalVideoStats stats: ByteRTCLocalVideoStats) {
        onLocalVideoStatsCallback?(
            Int(stats.encodedFrameWidth),
            Int(stats.encodedFrameHeight),
            Int(stats.sentKBitrate),
            Int(stats.encoderOutputFrameRate)
        )
    }

    func rtcEngine(_ engine: ByteRTCEngine, onLocalAudioStats stats: ByteRTCLocalAudioStats) {
        onLocalAudioStatsCallback?(
            Int(stats.sentKBitrate),
            0
        )
    }

    func clearEngineCallbacks() {
        onWarningCallback = nil
        onErrorCallback = nil
        onLocalVideoStatsCallback = nil
        onLocalAudioStatsCallback = nil
    }
}

// MARK: - Room Event Proxy

class RtcRoomEventProxy: NSObject, ByteRTCRoomDelegate {

    private let roomId: String

    var onRoomStateChangedCallback: ((_ roomId: String, _ uid: String, _ state: NSNumber, _ extraInfo: String) -> Void)?
    var onUserJoinedCallback: ((_ roomId: String, _ uid: String, _ elapsed: NSNumber) -> Void)?
    var onUserLeaveCallback: ((_ roomId: String, _ uid: String, _ reason: NSNumber) -> Void)?
    var onUserPublishStreamCallback: ((_ roomId: String, _ uid: String, _ streamIndex: String) -> Void)?
    var onUserUnpublishStreamCallback: ((_ roomId: String, _ uid: String, _ streamIndex: String) -> Void)?
    var onFirstRemoteVideoFrameDecodedCallback: ((_ roomId: String, _ uid: String, _ streamIndex: String, _ width: NSNumber, _ height: NSNumber, _ elapsed: NSNumber) -> Void)?
    var onRoomStatsCallback: ((_ roomId: String, _ userCount: NSNumber, _ duration: NSNumber) -> Void)?

    init(roomId: String) {
        self.roomId = roomId
        super.init()
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        onRoomStateChangedCallback?(roomId, uid, NSNumber(value: state), extraInfo)
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserJoined userInfo: ByteRTCUserInfo) {
        onUserJoinedCallback?(roomId, userInfo.userId ?? "", NSNumber(value: 0))
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserLeave uid: String, reason: ByteRTCUserOfflineReason) {
        onUserLeaveCallback?(roomId, uid, NSNumber(value: reason.rawValue))
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserPublishStream streamKey: ByteRTCRemoteStreamKey, isScreen: Bool, mediaStreamType type: ByteRTCMediaStreamType) {
        let uid = streamKey.userId ?? ""
        onUserPublishStreamCallback?(roomId, uid, isScreen ? "screen" : "main")
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserUnpublishStream streamKey: ByteRTCRemoteStreamKey, mediaStreamType type: ByteRTCMediaStreamType, reason: ByteRTCStreamRemoveReason) {
        let uid = streamKey.userId ?? ""
        onUserUnpublishStreamCallback?(roomId, uid, isScreen(streamKey) ? "screen" : "main")
    }

    private func isScreen(_ key: ByteRTCRemoteStreamKey) -> Bool {
        return key.streamIndex == .indexScreen
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStats stats: ByteRTCRoomStats) {
        onRoomStatsCallback?(roomId, NSNumber(value: stats.userCount), NSNumber(value: stats.duration))
    }

    func rtcRoom(_ rtcRoom: ByteRTCRoom, onFirstRemoteVideoFrameDecoded remoteStreamKey: ByteRTCRemoteStreamKey, withFrameInfo frameInfo: ByteRTCVideoFrameInfo) {
        let uid = remoteStreamKey.userId ?? ""
        let streamIndex: String
        switch remoteStreamKey.streamIndex {
        case .indexScreen:
            streamIndex = "screen"
        default:
            streamIndex = "main"
        }
        onFirstRemoteVideoFrameDecodedCallback?(roomId, uid, streamIndex, NSNumber(value: frameInfo.width), NSNumber(value: frameInfo.height), NSNumber(value: 0))
    }

    func clearCallbacks() {
        onRoomStateChangedCallback = nil
        onUserJoinedCallback = nil
        onUserLeaveCallback = nil
        onUserPublishStreamCallback = nil
        onUserUnpublishStreamCallback = nil
        onFirstRemoteVideoFrameDecodedCallback = nil
        onRoomStatsCallback = nil
    }

    // MARK: - Static management

    private static var roomProxies: [String: RtcRoomEventProxy] = [:]

    static func getOrCreate(roomId: String) -> RtcRoomEventProxy {
        if let existing = roomProxies[roomId] {
            return existing
        }
        let proxy = RtcRoomEventProxy(roomId: roomId)
        roomProxies[roomId] = proxy
        return proxy
    }

    static func remove(roomId: String) {
        roomProxies[roomId]?.clearCallbacks()
        roomProxies.removeValue(forKey: roomId)
    }

    static func clearAll() {
        for (_, proxy) in roomProxies {
            proxy.clearCallbacks()
        }
        roomProxies.removeAll()
    }
}
