# uts-any-rtc

UniApp UTS plugin wrapping [BytePlus RTC SDK](https://docs.byteplus.com/en/byteplus-rtc) for cross-platform real-time audio/video communication with beauty effects support.

## Features

- **RTC Engine** - Create/destroy RTC engine
- **Room Management** - Create/join/leave/destroy rooms
- **Audio** - Start/stop audio capture, mute, set audio route
- **Video** - Start/stop video capture, switch camera, mute, local/remote video rendering
- **Beauty Effects** - Built-in basic beauty (smooth, whiten, sharpen), advanced effects via BytePlus Effects SDK (requires license)
- **Event Callbacks** - Room state, user join/leave, stream publish/unpublish, video frame decoded
- **Native Video Component** - `any-rtc-video-view` for rendering local and remote video streams

## Platform Support

| Platform | SDK | Status |
|----------|-----|--------|
| Android | BytePlusRTC 3.60.1.2900 (AAR) | Tested |
| iOS | BytePlusRTC 3.60.1.2900 (CocoaPods) | Tested |

> **Important:** The iOS native Swift files are written for BytePlusRTC SDK 3.60.1. If you use a different SDK version, you may need to update the Swift API calls to match. See [iOS SDK Compatibility](#ios-sdk-compatibility) below.

## Quick Start

### 1. Install

Import the plugin from the uni-app plugin market, or copy `uni_modules/uts-any-rtc` and `uni_modules/any-rtc-video-view` to your project.

### 2. Get BytePlus RTC Credentials

1. Register at [BytePlus Console](https://console.byteplus.com)
2. Create an RTC application to get your `appId`
3. Generate temporary tokens for testing (Console > RTC > App Management)

### 3. Basic Usage

```javascript
import {
  createEngine,
  createRoom,
  joinRoom,
  startVideoCapture,
  startAudioCapture,
  onUserJoined,
  onUserPublishStream,
} from '@/uni_modules/uts-any-rtc'

// 1. Create engine
createEngine({
  appId: 'YOUR_APP_ID',
  success: () => {
    console.log('Engine created')
  }
})

// 2. Create and join room
createRoom({
  roomId: 'room001',
  success: () => {
    // Register events
    onUserJoined({
      roomId: 'room001',
      callback: (e) => console.log('User joined:', e.uid)
    })

    onUserPublishStream({
      roomId: 'room001',
      callback: (e) => console.log('User published:', e.uid)
    })

    // Join room
    joinRoom({
      roomId: 'room001',
      userId: 'user001',
      token: 'YOUR_TOKEN',
      isAutoPublish: true,
      isAutoSubscribeAudio: true,
      isAutoSubscribeVideo: true,
      success: () => console.log('Joined room')
    })
  }
})

// 3. Start capture
startVideoCapture({ success: () => {} })
startAudioCapture({ success: () => {} })
```

### 4. Video Rendering

Use the `any-rtc-video-view` component in `.nvue` pages:

```html
<!-- Local video -->
<any-rtc-video-view
  uid=""
  :renderMode="'hidden'"
  style="width: 100%; height: 400rpx;"
/>

<!-- Remote video -->
<any-rtc-video-view
  :uid="remoteUserId"
  :roomId="roomId"
  :renderMode="'hidden'"
  style="width: 100%; height: 400rpx;"
/>
```

> **Note:** In nvue pages, the component must have explicit width and height, otherwise it will not be visible.

### 5. Basic Beauty

```javascript
import { enableBeauty, setBeautyParam } from '@/uni_modules/uts-any-rtc'

// Enable beauty (no license needed for basic beauty)
enableBeauty({ enable: true })

// Set parameters
setBeautyParam({ mode: 'smooth', intensity: 0.8 })
setBeautyParam({ mode: 'whiten', intensity: 0.5 })
setBeautyParam({ mode: 'sharpen', intensity: 0.3 })
```

## API Reference

### Engine

| Function | Description |
|----------|-------------|
| `createEngine(options)` | Initialize RTC engine with appId |
| `destroyEngine(options)` | Destroy RTC engine and release resources |

### Room

| Function | Description |
|----------|-------------|
| `createRoom(options)` | Create a room |
| `joinRoom(options)` | Join a room with token authentication |
| `leaveRoom(options)` | Leave the current room |
| `destroyRoom(options)` | Destroy a room |

### Audio

| Function | Description |
|----------|-------------|
| `startAudioCapture(options)` | Start audio capture |
| `stopAudioCapture(options)` | Stop audio capture |
| `setAudioRoute(options)` | Set audio route (speaker/earpiece) |
| `muteLocalAudio(options)` | Mute/unmute local audio |

### Video

| Function | Description |
|----------|-------------|
| `startVideoCapture(options)` | Start video capture |
| `stopVideoCapture(options)` | Stop video capture |
| `switchCamera(options)` | Switch front/back camera |
| `muteLocalVideo(options)` | Mute/unmute local video |

### Beauty & Effects

| Function | Description |
|----------|-------------|
| `enableBeauty(options)` | Enable/disable basic beauty |
| `setBeautyParam(options)` | Set beauty parameter (smooth/whiten/sharpen) |
| `initEffects(options)` | Initialize Effects SDK (requires license) |
| `setFilter(options)` | Set color filter |
| `setSticker(options)` | Set sticker effect |
| `setVirtualBackground(options)` | Set virtual background |

### Events

Each event is registered as a separate function with `@UTSJS.keepAlive`:

| Function | Description |
|----------|-------------|
| `onRoomStateChanged(options)` | Room connection state changed |
| `onUserJoined(options)` | Remote user joined the room |
| `onUserLeave(options)` | Remote user left the room |
| `onUserPublishStream(options)` | Remote user published a stream |
| `onUserUnpublishStream(options)` | Remote user unpublished a stream |
| `onFirstRemoteVideoFrameDecoded(options)` | First remote video frame decoded |
| `onRoomStats(options)` | Room statistics |
| `onEngineWarning(options)` | Engine warning |
| `onEngineError(options)` | Engine error |
| `offRoomEvent(options)` | Remove room event listeners |
| `offEngineEvent(options)` | Remove engine event listeners |

## iOS SDK Compatibility

The iOS native Swift files in this plugin are written for **BytePlusRTC SDK 3.60.1**. This SDK version uses the older API naming convention:

| This Plugin Uses | Newer SDKs Use |
|-----------------|----------------|
| `ByteRTCEngine` | `ByteRTCVideo` |
| `ByteRTCEngineDelegate` | `ByteRTCVideoDelegate` |
| `ByteRTCEngineConfig` | Direct parameters |
| `ByteRTCRoomEx.publishStream(_:mediaStreamType:)` | `ByteRTCRoom.publishStream(_:)` |

If you upgrade the BytePlusRTC pod version, you will need to update the Swift files accordingly.

## Offline Packaging

### Android

Required Gradle dependencies:

```gradle
implementation "org.jetbrains.kotlin:kotlin-stdlib:2.2.0"
implementation "org.jetbrains.kotlin:kotlin-reflect:2.2.0"
implementation "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.1"
implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1"
implementation 'com.byteplus:BytePlusRTC:3.60.1.2900'
```

### iOS

The plugin uses CocoaPods for BytePlusRTC:

```ruby
pod 'BytePlusRTC', '3.60.1.2900'
```

Required system frameworks: AVFoundation, AudioToolbox, VideoToolbox, CoreMedia, CoreVideo, GLKit, OpenGLES, MetalKit, SystemConfiguration, CFNetwork, libc++, libresolv

## Event Callback Architecture

This plugin uses **separate functions for each event** (not a combined options object). This is required because uni-app's UTS bridge only generates proper callback serialization for the standard `success/fail/complete` pattern, not for custom-named callback properties in options objects.

```javascript
// Correct pattern (each event as separate function)
onUserJoined({
  roomId: 'room001',
  callback: (e) => console.log(e.uid)
})

// NOT supported (combined options object)
// onRoomEvent({ onUserJoined: (e) => {}, onUserLeave: (e) => {} })
```

## License

See [LICENSE](LICENSE) file.
