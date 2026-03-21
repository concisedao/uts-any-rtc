package uts.sdk.modules.utsAnyRtc

import com.ss.bytertc.engine.handler.IRTCEngineEventHandler
import com.ss.bytertc.engine.handler.IRTCRoomEventHandler
import com.ss.bytertc.engine.data.RemoteStreamKey
import com.ss.bytertc.engine.data.StreamIndex
import com.ss.bytertc.engine.data.VideoFrameInfo
import com.ss.bytertc.engine.type.MediaStreamType
import com.ss.bytertc.engine.type.RTCRoomStats
import com.ss.bytertc.engine.type.StreamRemoveReason

class RtcEventProxy : IRTCEngineEventHandler() {

    // Engine event callbacks
    var onWarningCallback: ((code: Int, message: String) -> Unit)? = null
    var onErrorCallback: ((code: Int, message: String) -> Unit)? = null
    var onFirstRemoteVideoFrameDecodedCallback: ((uid: String, streamIndex: String, width: Int, height: Int) -> Unit)? = null

    override fun onWarning(warn: Int) {
        onWarningCallback?.invoke(warn, "Warning code: $warn")
    }

    override fun onError(err: Int) {
        onErrorCallback?.invoke(err, "Error code: $err")
    }

    override fun onFirstRemoteVideoFrameDecoded(remoteStreamKey: RemoteStreamKey, frameInfo: VideoFrameInfo) {
        val uid = remoteStreamKey.userId ?: ""
        val streamIndex = when (remoteStreamKey.streamIndex) {
            StreamIndex.STREAM_INDEX_SCREEN -> "screen"
            else -> "main"
        }
        onFirstRemoteVideoFrameDecodedCallback?.invoke(uid, streamIndex, frameInfo.width, frameInfo.height)
    }

    fun clearEngineCallbacks() {
        onWarningCallback = null
        onErrorCallback = null
        onFirstRemoteVideoFrameDecodedCallback = null
    }

    // Room event handler — one per room
    class RoomEventHandler(private val roomId: String) : IRTCRoomEventHandler() {

        var onRoomStateChangedCallback: ((roomId: String, uid: String, state: Int, extraInfo: String) -> Unit)? = null
        var onUserJoinedCallback: ((roomId: String, uid: String) -> Unit)? = null
        var onUserLeaveCallback: ((roomId: String, uid: String, reason: Int) -> Unit)? = null
        var onUserPublishStreamCallback: ((roomId: String, uid: String, mediaType: String) -> Unit)? = null
        var onUserUnpublishStreamCallback: ((roomId: String, uid: String, mediaType: String) -> Unit)? = null
        var onRoomStatsCallback: ((roomId: String, userCount: Int, duration: Int) -> Unit)? = null

        override fun onRoomStateChanged(roomId: String, uid: String, state: Int, extraInfo: String) {
            onRoomStateChangedCallback?.invoke(roomId, uid, state, extraInfo)
        }

        override fun onUserJoined(userInfo: com.ss.bytertc.engine.UserInfo) {
            onUserJoinedCallback?.invoke(roomId, userInfo.uid)
        }

        override fun onUserLeave(uid: String, reason: Int) {
            onUserLeaveCallback?.invoke(roomId, uid, reason)
        }

        override fun onUserPublishStream(uid: String, type: MediaStreamType) {
            onUserPublishStreamCallback?.invoke(roomId, uid, "main")
        }

        override fun onUserUnpublishStream(uid: String, type: MediaStreamType, reason: StreamRemoveReason) {
            onUserUnpublishStreamCallback?.invoke(roomId, uid, "main")
        }

        override fun onRoomStats(stats: RTCRoomStats?) {
            stats?.let {
                onRoomStatsCallback?.invoke(roomId, it.users, it.totalDuration)
            }
        }

        fun clearCallbacks() {
            onRoomStateChangedCallback = null
            onUserJoinedCallback = null
            onUserLeaveCallback = null
            onUserPublishStreamCallback = null
            onUserUnpublishStreamCallback = null
            onRoomStatsCallback = null
        }
    }

    companion object {
        private val roomHandlers: MutableMap<String, RoomEventHandler> = mutableMapOf()

        fun getOrCreateRoomHandler(roomId: String): RoomEventHandler {
            return roomHandlers.getOrPut(roomId) { RoomEventHandler(roomId) }
        }

        fun removeRoomHandler(roomId: String) {
            roomHandlers[roomId]?.clearCallbacks()
            roomHandlers.remove(roomId)
        }

        fun clearAllRoomHandlers() {
            roomHandlers.values.forEach { it.clearCallbacks() }
            roomHandlers.clear()
        }
    }
}
