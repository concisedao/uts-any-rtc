# uts-any-rtc

基于 BytePlus RTC SDK 的 uni-app UTS 原生插件，提供跨平台实时音视频通话及美颜特效能力。

## 平台支持

| Android | iOS |
|:-------:|:---:|
| API 21+ | iOS 12.0+ |

## 前置条件

1. **BytePlus 账号** — 前往 [BytePlus RTC 控制台](https://console.byteplus.com/rtc) 注册并创建应用
2. 获取 **appId**
3. 服务端部署 **Token 生成服务**（参考 [BytePlus RTC Token 文档](https://docs.byteplus.com/rtc/docs/token)）
4. 如需使用美颜功能，还需获取 **Effects License 文件** 和 **模型资源包**

## 安装

### HBuilderX 插件市场

1. 在插件市场搜索 `uts-any-rtc`，点击导入
2. 同时导入配套视频渲染组件 `any-rtc-video-view`
3. 导入后需要 **制作自定义基座** 才能运行（插件包含原生 SDK 依赖）

### 手动安装

将以下目录复制到你的项目 `uni_modules/` 下：
- `uni_modules/uts-any-rtc` — 核心 API 插件
- `uni_modules/any-rtc-video-view` — 视频渲染组件

## 制作自定义基座

本插件依赖原生 BytePlus RTC SDK，标准基座不包含该依赖，必须制作自定义基座：

**HBuilderX:** 运行 → 运行到手机或模拟器 → 制作自定义调试基座

首次编译约需 3~5 分钟（下载原生 SDK 依赖），后续增量编译较快。

## 权限配置

### Android

在 `AndroidManifest.xml` 或 `manifest.json` 中添加：

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS

在 `Info.plist` 或 `manifest.json` 中添加：

```
NSCameraUsageDescription: 需要访问摄像头以进行视频通话
NSMicrophoneUsageDescription: 需要访问麦克风以进行语音通话
```

> **注意：** 本插件仅检查权限状态，不主动发起权限请求。请在调用 `startVideoCapture` / `startAudioCapture` 之前，使用 uni-app 的 `uni.authorize` 或第三方权限插件先行申请权限。

## 快速开始

### 重要：视频组件必须在 nvue 页面中使用

`<any-rtc-video-view>` 是兼容模式原生组件，**只能在 `.nvue` 页面中使用**。普通 `.vue` 页面无法渲染原生视频 View。

如果你的页面不需要视频渲染（例如只做纯音频通话），可以在普通 `.vue` 页面中调用 API。

### 1. 基础音视频通话

创建一个 `.nvue` 页面（例如 `pages/call/call.nvue`）：

```html
<template>
  <view>
    <!-- 本地预览 -->
    <any-rtc-video-view uid="" style="width: 200px; height: 200px;" />
    <!-- 远端视频 -->
    <any-rtc-video-view :uid="remoteUid" :roomId="roomId" style="width: 200px; height: 200px;" />
    <button @click="start">开始通话</button>
    <button @click="stop">结束通话</button>
  </view>
</template>

<script>
  import {
    createEngine, destroyEngine,
    createRoom, joinRoom, leaveRoom, destroyRoom,
    startAudioCapture, startVideoCapture,
    stopAudioCapture, stopVideoCapture,
    onRoomEvent, offRoomEvent,
  } from '@/uni_modules/uts-any-rtc'

  export default {
    data() {
      return {
        roomId: 'my_room',
        remoteUid: '',
      }
    },
    methods: {
      start() {
        // 1. 创建引擎
        createEngine({
          appId: 'YOUR_APP_ID',
          success: (_) => {
            // 2. 创建房间
            createRoom({
              roomId: this.roomId,
              success: (_) => {
                // 3. 注册房间事件
                onRoomEvent({
                  roomId: this.roomId,
                  onUserJoined: (e) => {
                    this.remoteUid = e.uid
                  },
                  onUserLeave: (e) => {
                    if (e.uid == this.remoteUid) this.remoteUid = ''
                  },
                })
                // 4. 开启音视频采集
                startAudioCapture({})
                startVideoCapture({})
                // 5. 加入房间
                joinRoom({
                  roomId: this.roomId,
                  userId: 'user_001',
                  token: 'YOUR_TOKEN',
                  isAutoPublish: true,
                  isAutoSubscribeAudio: true,
                  isAutoSubscribeVideo: true,
                })
              },
            })
          },
        })
      },
      stop() {
        stopAudioCapture({})
        stopVideoCapture({})
        leaveRoom({ roomId: this.roomId })
        offRoomEvent({ roomId: this.roomId })
        destroyRoom({ roomId: this.roomId })
        destroyEngine({})
        this.remoteUid = ''
      }
    }
  }
</script>
```

### 2. 使用美颜

```js
import { initEffects, enableBeauty, setBeautyParam, disposeEffects } from '@/uni_modules/uts-any-rtc'

// 初始化美颜（在 createEngine 之后）
initEffects({
  licensePath: '/path/to/license.lic',
  modelPath: '/path/to/models/',
  success: (_) => {
    // 开启美颜
    enableBeauty({ enable: true })
    // 设置磨皮强度
    setBeautyParam({ mode: 'smooth', intensity: 0.8 })
    // 设置美白强度
    setBeautyParam({ mode: 'whiten', intensity: 0.5 })
  },
})

// 释放美颜资源（在 destroyEngine 之前，非必须，destroyEngine 会自动释放）
disposeEffects({})
```

## 视频渲染组件

`<any-rtc-video-view>` 是配套的视频渲染组件（独立 uni_module：`any-rtc-video-view`），内部自动创建原生 View 并绑定 canvas。

**注意：该组件只能在 `.nvue` 页面中使用。**

### Props

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `uid` | string | `''` | 用户 ID。空字符串 = 本地预览 |
| `roomId` | string | `''` | 房间 ID。远端视频必传 |
| `renderMode` | string | `'hidden'` | `'hidden'` / `'fit'` / `'fill'` |
| `mirrorType` | string | `'none'` | `'none'` / `'render'` / `'renderAndEncoder'` |
| `streamIndex` | string | `'main'` | `'main'` / `'screen'` |

### 示例

```html
<!-- 本地预览（uid 为空） -->
<any-rtc-video-view uid="" style="width: 100%; height: 300px;" />

<!-- 远端视频 -->
<any-rtc-video-view
  :uid="remoteUserId"
  :roomId="roomId"
  renderMode="fit"
  style="width: 100%; height: 300px;"
/>
```

## 完整 API

所有函数遵循 uni-app 规范，接受单个 options 对象，支持 `success` / `fail` / `complete` 回调。

### 引擎

| 函数 | 说明 |
|------|------|
| `createEngine(options)` | 初始化 RTC 引擎。`options.appId` 必传 |
| `destroyEngine(options)` | 销毁引擎，自动释放所有房间和美颜资源 |

### 房间

| 函数 | 说明 |
|------|------|
| `createRoom(options)` | 创建房间实例。`options.roomId` 必传 |
| `joinRoom(options)` | 加入房间。需传入 `roomId` / `userId` / `token` |
| `leaveRoom(options)` | 离开房间 |
| `destroyRoom(options)` | 销毁房间实例 |

**joinRoom options:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:----:|--------|------|
| roomId | string | Y | | 房间 ID |
| userId | string | Y | | 用户 ID |
| token | string | Y | | 鉴权 Token |
| userName | string | N | `''` | 用户名 |
| roomProfile | string | N | `'communication'` | `'communication'` / `'liveBroadcasting'` / `'game'` / `'cloudGame'` |
| isAutoPublish | boolean | N | `true` | 自动发布流 |
| isAutoSubscribeAudio | boolean | N | `true` | 自动订阅音频 |
| isAutoSubscribeVideo | boolean | N | `true` | 自动订阅视频 |

### 音频

| 函数 | 说明 |
|------|------|
| `startAudioCapture(options)` | 开启麦克风采集。需先授予麦克风权限 |
| `stopAudioCapture(options)` | 停止麦克风采集 |
| `setAudioRoute(options)` | 切换听筒/扬声器。`options.route`: `'earpiece'` / `'speaker'` |
| `muteLocalAudio(options)` | 静音/取消静音。`options.mute` + `options.roomId` |

### 视频

| 函数 | 说明 |
|------|------|
| `startVideoCapture(options)` | 开启摄像头采集。需先授予摄像头权限 |
| `stopVideoCapture(options)` | 停止摄像头采集 |
| `switchCamera(options)` | 切换前后摄像头。`options.facing`: `'front'` / `'back'` |
| `muteLocalVideo(options)` | 停止/恢复发布视频流。`options.mute` + `options.roomId` |
| `setVideoEncoderConfig(options)` | 设置编码参数：`width` / `height` / `frameRate` / `bitrate` |

### 美颜特效

| 函数 | 说明 |
|------|------|
| `initEffects(options)` | 初始化美颜。`options.licensePath` + `options.modelPath` |
| `enableBeauty(options)` | 开关美颜。`options.enable`: boolean |
| `setBeautyParam(options)` | 设置美颜参数。`options.mode`: `'whiten'` / `'smooth'` / `'sharpen'`，`options.intensity`: 0~1 |
| `setFilter(options)` | 设置滤镜。`options.filterPath` + `options.intensity`(默认 0.5) |
| `setSticker(options)` | 设置贴纸。`options.stickerPath` |
| `setEffectNodes(options)` | 设置特效节点。`options.nodePaths`: string[] |
| `updateEffectNode(options)` | 更新特效节点参数。`options.nodePath` / `options.key` / `options.value` |
| `setVirtualBackground(options)` | 设置虚拟背景。`options.sourceType`: `'color'` / `'image'`，`options.sourceValue`: 颜色值或图片路径 |
| `disableVirtualBackground(options)` | 关闭虚拟背景 |
| `disposeEffects(options)` | 释放美颜资源 |

### 事件监听

| 函数 | 说明 |
|------|------|
| `onRoomEvent(options)` | 注册房间事件回调 |
| `offRoomEvent(options)` | 移除房间事件回调 |
| `onEngineEvent(options)` | 注册引擎事件回调 |
| `offEngineEvent(options)` | 移除引擎事件回调 |

**房间事件 (onRoomEvent):**

| 回调 | 参数 | 说明 |
|------|------|------|
| `onRoomStateChanged` | `{ roomId, uid, state, extraInfo }` | 房间状态变化（加入成功、断开等） |
| `onUserJoined` | `{ roomId, uid, elapsed }` | 远端用户加入房间 |
| `onUserLeave` | `{ roomId, uid, reason }` | 远端用户离开房间 |
| `onUserPublishStream` | `{ roomId, uid, streamIndex }` | 远端用户开始发布流 |
| `onUserUnpublishStream` | `{ roomId, uid, streamIndex }` | 远端用户停止发布流 |
| `onFirstRemoteVideoFrameDecoded` | `{ roomId, uid, streamIndex, width, height, elapsed }` | 首帧远端视频解码 |
| `onRoomStats` | `{ roomId, userCount, duration }` | 房间统计信息（周期性回调） |

**引擎事件 (onEngineEvent):**

| 回调 | 参数 | 说明 |
|------|------|------|
| `onWarning` | `{ code, message }` | SDK 警告 |
| `onError` | `{ code, message }` | SDK 错误 |
| `onLocalVideoStats` | `{ width, height, sentKBitrate, frameRate }` | 本地视频统计 |
| `onLocalAudioStats` | `{ sentKBitrate, audioLevel }` | 本地音频统计 |

## 错误码

| 错误码 | 说明 |
|--------|------|
| 9010001 | 引擎未初始化。请先调用 `createEngine()` |
| 9010002 | 引擎已初始化。请先调用 `destroyEngine()` |
| 9010003 | 房间未创建。请先调用 `createRoom()` |
| 9010004 | 房间已加入 |
| 9010005 | 房间未加入 |
| 9010006 | 摄像头权限未授予 |
| 9010007 | 麦克风权限未授予 |
| 9010008 | 美颜未初始化。请先调用 `initEffects()` |
| 9010009 | 美颜 License 无效或过期 |
| 9010010 | 参数无效 |
| 9010011 | SDK 内部错误 |
| 9010012 | 美颜资源文件未找到 |

## 调用流程

```
createEngine
  ├── onEngineEvent          (可选，注册引擎级事件)
  ├── initEffects            (可选，使用美颜时)
  │    ├── enableBeauty
  │    ├── setBeautyParam
  │    └── ...
  ├── startAudioCapture
  ├── startVideoCapture
  ├── createRoom
  │    ├── onRoomEvent       (注册房间事件)
  │    ├── joinRoom
  │    │    ├── 通话中...
  │    │    ├── muteLocalAudio / muteLocalVideo
  │    │    └── switchCamera
  │    ├── leaveRoom
  │    └── offRoomEvent
  ├── destroyRoom
  ├── stopAudioCapture
  ├── stopVideoCapture
  ├── disposeEffects         (可选)
  └── offEngineEvent
destroyEngine
```

## 注意事项

1. **必须制作自定义基座** — 标准基座不包含 BytePlus RTC 原生 SDK
2. **视频组件必须在 nvue 页面使用** — `<any-rtc-video-view>` 是兼容模式原生组件，只能在 `.nvue` 页面中渲染
3. **先申请权限再采集** — `startVideoCapture` / `startAudioCapture` 仅检查权限，不弹窗申请
4. **Token 安全** — Token 应由服务端生成，切勿将 AppKey 写在客户端
5. **生命周期** — 插件内部已处理 App 切后台自动暂停视频、切前台自动恢复
6. **多房间** — 支持同时加入多个房间，通过 `roomId` 区分
7. **组件依赖** — 使用视频组件需同时安装 `any-rtc-video-view` uni_module
