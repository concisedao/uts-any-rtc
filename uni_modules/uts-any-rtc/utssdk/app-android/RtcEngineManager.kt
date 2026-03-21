package uts.sdk.modules.utsAnyRtc

import android.content.Context
import android.view.TextureView
import com.ss.bytertc.engine.RTCEngine
import com.ss.bytertc.engine.VideoCanvas
import com.ss.bytertc.engine.VideoEncoderConfig
import com.ss.bytertc.engine.data.AudioRoute
import com.ss.bytertc.engine.data.CameraId
import com.ss.bytertc.engine.data.EngineConfig
import com.ss.bytertc.engine.data.RemoteStreamKey
import com.ss.bytertc.engine.data.StreamIndex

object RtcEngineManager {

    private var rtcEngine: RTCEngine? = null
    var isCapturingAudio: Boolean = false
        private set
    var isCapturingVideo: Boolean = false
        private set
    private var wasCapturingVideo: Boolean = false
    private var currentCameraId: CameraId = CameraId.CAMERA_ID_FRONT

    @Synchronized
    fun createEngine(context: Context, appId: String, handler: RtcEventProxy): RTCEngine? {
        if (rtcEngine != null) {
            return null
        }
        val config = EngineConfig()
        config.context = context.applicationContext
        config.appID = appId
        rtcEngine = RTCEngine.createRTCEngine(config, handler)
        return rtcEngine
    }

    @Synchronized
    fun destroyEngine() {
        stopAudioCapture()
        stopVideoCapture()
        RtcRoomManager.destroyAllRooms()
        RTCEngine.destroyRTCEngine()
        rtcEngine = null
        isCapturingAudio = false
        isCapturingVideo = false
        wasCapturingVideo = false
    }

    fun getEngine(): RTCEngine? {
        return rtcEngine
    }

    fun isInitialized(): Boolean {
        return rtcEngine != null
    }

    // Audio
    fun startAudioCapture() {
        rtcEngine?.startAudioCapture()
        isCapturingAudio = true
    }

    fun stopAudioCapture() {
        rtcEngine?.stopAudioCapture()
        isCapturingAudio = false
    }

    fun setDefaultAudioRoute(useSpeaker: Boolean) {
        rtcEngine?.setDefaultAudioRoute(
            if (useSpeaker) AudioRoute.AUDIO_ROUTE_SPEAKERPHONE
            else AudioRoute.AUDIO_ROUTE_EARPIECE
        )
    }

    // Video
    fun startVideoCapture() {
        rtcEngine?.startVideoCapture()
        isCapturingVideo = true
    }

    fun stopVideoCapture() {
        rtcEngine?.stopVideoCapture()
        isCapturingVideo = false
    }

    fun switchCamera(cameraId: CameraId) {
        currentCameraId = cameraId
        rtcEngine?.switchCamera(cameraId)
    }

    fun setLocalVideoCanvas(streamIndex: StreamIndex, canvas: VideoCanvas?) {
        rtcEngine?.setLocalVideoCanvas(streamIndex, canvas)
    }

    fun setRemoteVideoCanvas(roomId: String, uid: String, streamIndex: StreamIndex, canvas: VideoCanvas?) {
        val remoteStreamKey = RemoteStreamKey(roomId, uid, streamIndex)
        rtcEngine?.setRemoteVideoCanvas(remoteStreamKey, canvas)
    }

    fun setVideoEncoderConfig(config: VideoEncoderConfig) {
        rtcEngine?.setVideoEncoderConfig(config)
    }

    // Lifecycle
    fun onAppPause() {
        if (isCapturingVideo) {
            wasCapturingVideo = true
            rtcEngine?.stopVideoCapture()
            isCapturingVideo = false
        }
    }

    fun onAppResume() {
        if (wasCapturingVideo) {
            rtcEngine?.startVideoCapture()
            isCapturingVideo = true
            wasCapturingVideo = false
        }
    }

    // View creation helper
    fun createTextureView(context: Context): TextureView {
        return TextureView(context)
    }
}
