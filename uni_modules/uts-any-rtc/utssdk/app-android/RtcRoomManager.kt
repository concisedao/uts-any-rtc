package uts.sdk.modules.utsAnyRtc

import com.ss.bytertc.engine.RTCRoom
import com.ss.bytertc.engine.RTCRoomConfig
import com.ss.bytertc.engine.UserInfo
import com.ss.bytertc.engine.type.ChannelProfile

object RtcRoomManager {

    private val rooms: MutableMap<String, RTCRoom> = mutableMapOf()

    @Synchronized
    fun createRoom(roomId: String): RTCRoom? {
        if (rooms.containsKey(roomId)) {
            return rooms[roomId]
        }
        val engine = RtcEngineManager.getEngine() ?: return null
        val room = engine.createRTCRoom(roomId) ?: return null
        rooms[roomId] = room
        return room
    }

    fun getRoom(roomId: String): RTCRoom? {
        return rooms[roomId]
    }

    fun hasRoom(roomId: String): Boolean {
        return rooms.containsKey(roomId)
    }

    fun joinRoom(
        roomId: String,
        token: String,
        userId: String,
        userName: String?,
        channelProfile: ChannelProfile,
        isAutoPublishAudio: Boolean,
        isAutoPublishVideo: Boolean,
        isAutoSubscribeAudio: Boolean,
        isAutoSubscribeVideo: Boolean
    ): Int {
        val room = rooms[roomId] ?: return -1
        val userInfo = UserInfo(userId, userName ?: "")
        val roomConfig = RTCRoomConfig(
            channelProfile,
            isAutoPublishAudio,
            isAutoPublishVideo,
            isAutoSubscribeAudio,
            isAutoSubscribeVideo
        )
        return room.joinRoom(token, userInfo, roomConfig)
    }

    fun leaveRoom(roomId: String) {
        rooms[roomId]?.leaveRoom()
    }

    @Synchronized
    fun destroyRoom(roomId: String) {
        rooms[roomId]?.leaveRoom()
        rooms[roomId]?.destroy()
        rooms.remove(roomId)
    }

    @Synchronized
    fun destroyAllRooms() {
        rooms.values.forEach { room ->
            room.leaveRoom()
            room.destroy()
        }
        rooms.clear()
    }

    fun setRoomEventHandler(roomId: String, handler: RtcEventProxy.RoomEventHandler) {
        rooms[roomId]?.setRTCRoomEventHandler(handler)
    }

    fun muteLocalVideo(roomId: String, mute: Boolean) {
        val room = rooms[roomId] ?: return
        room.publishStreamVideo(!mute)
    }

    fun muteLocalAudio(roomId: String, mute: Boolean) {
        val room = rooms[roomId] ?: return
        room.publishStreamAudio(!mute)
    }
}
