import Foundation
import BytePlusRTC

class RtcTypeConverter {

    static func toChannelProfile(_ profile: String?) -> ByteRTCRoomProfile {
        switch profile {
        case "communication":
            return .communication
        case "liveBroadcasting":
            return .liveBroadcasting
        case "game":
            return .game
        case "cloudGame":
            return .cloudGame
        default:
            return .communication
        }
    }

    static func toStreamIndex(_ index: String?) -> ByteRTCStreamIndex {
        switch index {
        case "main":
            return .indexMain
        case "screen":
            return .indexScreen
        default:
            return .indexMain
        }
    }

    static func toCameraId(_ facing: String?) -> ByteRTCCameraID {
        switch facing {
        case "front":
            return .front
        case "back":
            return .back
        default:
            return .front
        }
    }

    static func toMirrorType(_ type: String?) -> ByteRTCMirrorType {
        switch type {
        case "none":
            return .none
        case "render":
            return .render
        case "renderAndEncoder":
            return .renderAndEncoder
        default:
            return .none
        }
    }

    static func toRenderMode(_ mode: String?) -> ByteRTCRenderMode {
        switch mode {
        case "hidden":
            return .hidden
        case "fit":
            return .fit
        case "fill":
            return .fill
        default:
            return .hidden
        }
    }

    static func toEffectBeautyMode(_ mode: String) -> ByteRTCEffectBeautyMode {
        switch mode {
        case "whiten":
            return .white
        case "smooth":
            return .smooth
        case "sharpen":
            return .sharpen
        default:
            return .smooth
        }
    }
}
