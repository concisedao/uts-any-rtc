package uts.sdk.modules.utsAnyRtc

import com.ss.bytertc.engine.VideoCanvas
import com.ss.bytertc.engine.data.CameraId
import com.ss.bytertc.engine.data.EffectBeautyMode
import com.ss.bytertc.engine.data.MirrorType
import com.ss.bytertc.engine.data.StreamIndex
import com.ss.bytertc.engine.type.ChannelProfile

object RtcTypeConverter {

    fun toChannelProfile(profile: String?): ChannelProfile {
        return when (profile) {
            "communication" -> ChannelProfile.CHANNEL_PROFILE_COMMUNICATION
            "liveBroadcasting" -> ChannelProfile.CHANNEL_PROFILE_LIVE_BROADCASTING
            "game" -> ChannelProfile.CHANNEL_PROFILE_GAME
            "cloudGame" -> ChannelProfile.CHANNEL_PROFILE_CLOUD_GAME
            else -> ChannelProfile.CHANNEL_PROFILE_COMMUNICATION
        }
    }

    fun toStreamIndex(index: String?): StreamIndex {
        return when (index) {
            "main" -> StreamIndex.STREAM_INDEX_MAIN
            "screen" -> StreamIndex.STREAM_INDEX_SCREEN
            else -> StreamIndex.STREAM_INDEX_MAIN
        }
    }

    fun toCameraId(facing: String?): CameraId {
        return when (facing) {
            "front" -> CameraId.CAMERA_ID_FRONT
            "back" -> CameraId.CAMERA_ID_BACK
            else -> CameraId.CAMERA_ID_FRONT
        }
    }

    fun toMirrorType(type: String?): MirrorType {
        return when (type) {
            "none" -> MirrorType.MIRROR_TYPE_NONE
            "render" -> MirrorType.MIRROR_TYPE_RENDER
            "renderAndEncoder" -> MirrorType.MIRROR_TYPE_RENDER_AND_ENCODER
            else -> MirrorType.MIRROR_TYPE_NONE
        }
    }

    fun toRenderMode(mode: String?): Int {
        return when (mode) {
            "hidden" -> VideoCanvas.RENDER_MODE_HIDDEN
            "fit" -> VideoCanvas.RENDER_MODE_FIT
            "fill" -> VideoCanvas.RENDER_MODE_FILL
            else -> VideoCanvas.RENDER_MODE_HIDDEN
        }
    }

    fun toEffectBeautyMode(mode: String): EffectBeautyMode {
        return when (mode) {
            "whiten" -> EffectBeautyMode.WHITE
            "smooth" -> EffectBeautyMode.SMOOTH
            "sharpen" -> EffectBeautyMode.SHARPEN
            "clear" -> EffectBeautyMode.CLEAR
            else -> EffectBeautyMode.SMOOTH
        }
    }
}
