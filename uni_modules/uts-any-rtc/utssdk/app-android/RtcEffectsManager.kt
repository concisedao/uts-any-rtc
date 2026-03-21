package uts.sdk.modules.utsAnyRtc

import com.ss.bytertc.engine.data.EffectBeautyMode
import com.ss.bytertc.engine.data.VirtualBackgroundSource
import com.ss.bytertc.engine.data.VirtualBackgroundSourceType
import com.ss.bytertc.engine.video.IVideoEffect
import io.dcloud.uts.UTSArray

object RtcEffectsManager {

    private var isEffectsInitialized: Boolean = false
    private var videoEffect: IVideoEffect? = null

    fun initEffects(licensePath: String, modelPath: String): Int {
        val engine = RtcEngineManager.getEngine() ?: return -1
        return try {
            val effect = engine.getVideoEffectInterface()
            if (effect == null) return -1
            val ret = effect.initCVResource(licensePath, modelPath)
            if (ret == 0) {
                effect.enableVideoEffect()
                videoEffect = effect
                isEffectsInitialized = true
            }
            ret
        } catch (e: Exception) {
            -2
        }
    }

    fun isInitialized(): Boolean {
        return isEffectsInitialized
    }

    fun enableBeauty(enable: Boolean): Int {
        val engine = RtcEngineManager.getEngine() ?: return -1
        return try {
            engine.enableEffectBeauty(enable)
            0
        } catch (e: Exception) { -1 }
    }

    fun setBeautyParam(mode: EffectBeautyMode, intensity: Float): Int {
        val engine = RtcEngineManager.getEngine() ?: return -1
        return try {
            engine.setBeautyIntensity(mode, intensity)
            0
        } catch (e: Exception) { -1 }
    }

    fun setEffectNodes(nodePaths: UTSArray<String>): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            effect.setEffectNodes(nodePaths.toMutableList())
            0
        } catch (e: Exception) { -1 }
    }

    fun updateEffectNode(nodePath: String, key: String, value: Float): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            effect.updateEffectNode(nodePath, key, value)
            0
        } catch (e: Exception) { -1 }
    }

    fun setColorFilter(filterPath: String): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            effect.setColorFilter(filterPath)
            0
        } catch (e: Exception) { -1 }
    }

    fun setColorFilterIntensity(intensity: Float): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            effect.setColorFilterIntensity(intensity)
            0
        } catch (e: Exception) { -1 }
    }

    fun setVirtualBackground(sourcePath: String, sourceType: String): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            val bgSource = VirtualBackgroundSource()
            if (sourceType == "color") {
                bgSource.sourceType = VirtualBackgroundSourceType.COLOR
                bgSource.sourceColor = android.graphics.Color.parseColor(sourcePath)
            } else {
                bgSource.sourceType = VirtualBackgroundSourceType.IMAGE
                bgSource.sourcePath = sourcePath
            }
            effect.enableVirtualBackground("", bgSource)
            0
        } catch (e: Exception) { -1 }
    }

    fun disableVirtualBackground(): Int {
        if (!isEffectsInitialized) return -1
        val effect = videoEffect ?: return -1
        return try {
            effect.disableVirtualBackground()
            0
        } catch (e: Exception) { -1 }
    }

    fun dispose() {
        if (!isEffectsInitialized) return
        try {
            val engine = RtcEngineManager.getEngine()
            engine?.enableEffectBeauty(false)
            videoEffect?.disableVideoEffect()
        } catch (_: Exception) {
        }
        videoEffect = null
        isEffectsInitialized = false
    }
}
