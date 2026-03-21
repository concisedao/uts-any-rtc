import Foundation
import BytePlusRTC

class RtcRoomManager {

    static let shared = RtcRoomManager()

    private var rooms: [String: ByteRTCRoom] = [:]

    private init() {}

    @discardableResult
    func createRoom(roomId: String) -> ByteRTCRoom? {
        if let existing = rooms[roomId] {
            return existing
        }
        guard let engine = RtcEngineManager.shared.getEngine() else { return nil }
        guard let room = engine.createRTCRoom(roomId) else { return nil }
        rooms[roomId] = room
        return room
    }

    func getRoom(roomId: String) -> ByteRTCRoom? {
        return rooms[roomId]
    }

    func hasRoom(roomId: String) -> Bool {
        return rooms[roomId] != nil
    }

    func joinRoom(
        roomId: String,
        token: String,
        userId: String,
        userName: String?,
        channelProfile: ByteRTCRoomProfile,
        isAutoPublish: Bool,
        isAutoSubscribeAudio: Bool,
        isAutoSubscribeVideo: Bool
    ) -> Int32 {
        guard let room = rooms[roomId] else { return -1 }

        let userInfo = ByteRTCUserInfo()
        userInfo.userId = userId
        userInfo.extraInfo = userName ?? ""

        let roomConfig = ByteRTCRoomConfig()
        roomConfig.profile = channelProfile
        roomConfig.isAutoSubscribeAudio = isAutoSubscribeAudio
        roomConfig.isAutoSubscribeVideo = isAutoSubscribeVideo

        let ret = room.joinRoom(token, userInfo: userInfo, roomConfig: roomConfig)

        // Auto publish after join if needed
        if isAutoPublish && ret == 0 {
            if let roomEx = room as? ByteRTCRoomEx {
                roomEx.publishStream(.indexMain, mediaStreamType: .both)
            }
        }

        return ret
    }

    func leaveRoom(roomId: String) {
        rooms[roomId]?.leaveRoom()
    }

    func destroyRoom(roomId: String) {
        rooms[roomId]?.leaveRoom()
        rooms[roomId]?.destroy()
        rooms.removeValue(forKey: roomId)
    }

    func destroyAllRooms() {
        for (_, room) in rooms {
            room.leaveRoom()
            room.destroy()
        }
        rooms.removeAll()
    }

    func setRoomDelegate(roomId: String, delegate: ByteRTCRoomDelegate) {
        rooms[roomId]?.delegate = delegate
    }

    func muteLocalStream(roomId: String, mediaType: ByteRTCMediaStreamType, mute: Bool) {
        guard let room = rooms[roomId] else { return }
        guard let roomEx = room as? ByteRTCRoomEx else { return }
        if mute {
            roomEx.unpublishStream(.indexMain, mediaStreamType: mediaType)
        } else {
            roomEx.publishStream(.indexMain, mediaStreamType: mediaType)
        }
    }
}
