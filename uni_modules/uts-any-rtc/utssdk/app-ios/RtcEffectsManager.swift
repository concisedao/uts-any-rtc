import Foundation
import BytePlusRTC

class RtcEffectsManager {

    static let shared = RtcEffectsManager()

    private var isEffectsInitialized: Bool = false
    private var videoEffect: ByteRTCVideoEffect?

    private init() {}

    func initEffects(licensePath: String, modelPath: String) -> Int32 {
        guard let engine = RtcEngineManager.shared.getEngine() else { return -1 }
        guard let effect = engine.getVideoEffectInterface() else { return -1 }
        let ret = effect.initCVResource(licensePath, withAlgoModelDir: modelPath)
        if ret == 0 {
            effect.enable()
            videoEffect = effect
            isEffectsInitialized = true
        }
        return ret
    }

    func isInitialized() -> Bool {
        return isEffectsInitialized
    }

    func enableBeauty(_ enable: Bool) -> Int32 {
        guard let engine = RtcEngineManager.shared.getEngine() else { return -1 }
        engine.enableEffectBeauty(enable)
        return 0
    }

    func setBeautyParam(mode: ByteRTCEffectBeautyMode, intensity: Float) -> Int32 {
        guard let engine = RtcEngineManager.shared.getEngine() else { return -1 }
        engine.setBeautyIntensity(mode, withIntensity: intensity)
        return 0
    }

    func setEffectNodes(_ nodePaths: [String]) -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        effect.setEffectNodes(nodePaths)
        return 0
    }

    func updateEffectNode(nodePath: String, key: String, value: Float) -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        effect.updateNode(nodePath, key: key, value: value)
        return 0
    }

    func setColorFilter(_ filterPath: String) -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        effect.setColorFilter(filterPath)
        return 0
    }

    func setColorFilterIntensity(_ intensity: Float) -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        effect.setColorFilterIntensity(intensity)
        return 0
    }

    func setVirtualBackground(sourcePath: String, sourceType: String) -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        let bgSource = ByteRTCVirtualBackgroundSource()
        if sourceType == "color" {
            bgSource.sourceType = .color
            bgSource.sourceColor = Int32(parseHexColor(sourcePath))
        } else {
            bgSource.sourceType = .image
            bgSource.sourcePath = sourcePath
        }
        effect.enableVirtualBackground("", with: bgSource)
        return 0
    }

    func disableVirtualBackground() -> Int32 {
        guard isEffectsInitialized, let effect = videoEffect else { return -1 }
        effect.disableVirtualBackground()
        return 0
    }

    func dispose() {
        guard isEffectsInitialized else { return }
        if let effect = videoEffect {
            effect.disableVideoEffect()
        }
        if let engine = RtcEngineManager.shared.getEngine() {
            engine.enableEffectBeauty(false)
        }
        videoEffect = nil
        isEffectsInitialized = false
    }

    private func parseHexColor(_ hex: String) -> Int {
        var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexStr.hasPrefix("#") { hexStr.removeFirst() }
        var color: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&color)
        return Int(color)
    }
}
