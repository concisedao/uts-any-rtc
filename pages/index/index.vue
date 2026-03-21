<template>
  <view class="container">
    <text class="title">uts-any-rtc</text>
    <text class="desc">BytePlus RTC + Effects Plugin</text>

    <button class="btn-primary" @click="goTest">API Test Page</button>

    <view class="info-card">
      <text class="info-title">Before Testing</text>
      <text class="info-item">1. Get appId from BytePlus RTC Console</text>
      <text class="info-item">2. Generate a token from your server</text>
      <text class="info-item">3. Grant camera & microphone permissions</text>
      <text class="info-item">4. Use custom base (not standard base)</text>
    </view>

    <view class="info-card">
      <text class="info-title">Quick Permission Request</text>
      <button class="btn-small" size="mini" @click="requestCamera">Request Camera</button>
      <button class="btn-small" size="mini" @click="requestMic">Request Microphone</button>
    </view>
  </view>
</template>

<script>
  export default {
    methods: {
      goTest() {
        uni.navigateTo({ url: '/pages/test/test' })
      },
      requestCamera() {
        // #ifdef APP-PLUS
        const sysInfo = uni.getSystemInfoSync()
        if (sysInfo.platform === 'android') {
          plus.android.requestPermissions(
            ['android.permission.CAMERA'],
            (result) => {
              if (result.granted.length > 0) {
                uni.showToast({ title: 'Camera OK', icon: 'success' })
              } else {
                uni.showToast({ title: 'Camera Denied', icon: 'none' })
              }
            },
            (err) => {
              uni.showToast({ title: 'Camera request error', icon: 'none' })
            }
          )
        } else {
          // iOS: 系统会在首次使用时自动弹出权限请求
          uni.showToast({ title: 'iOS auto-prompts on use', icon: 'none' })
        }
        // #endif
      },
      requestMic() {
        // #ifdef APP-PLUS
        const sysInfo = uni.getSystemInfoSync()
        if (sysInfo.platform === 'android') {
          plus.android.requestPermissions(
            ['android.permission.RECORD_AUDIO'],
            (result) => {
              if (result.granted.length > 0) {
                uni.showToast({ title: 'Microphone OK', icon: 'success' })
              } else {
                uni.showToast({ title: 'Mic Denied', icon: 'none' })
              }
            },
            (err) => {
              uni.showToast({ title: 'Mic request error', icon: 'none' })
            }
          )
        } else {
          uni.showToast({ title: 'iOS auto-prompts on use', icon: 'none' })
        }
        // #endif
      }
    }
  }
</script>

<style>
  .container {
    padding: 40rpx;
  }
  .title {
    font-size: 48rpx;
    font-weight: bold;
    text-align: center;
    margin-top: 60rpx;
  }
  .desc {
    font-size: 28rpx;
    color: #888888;
    text-align: center;
    margin-top: 12rpx;
    margin-bottom: 60rpx;
  }
  .btn-primary {
    margin-bottom: 40rpx;
  }
  .btn-small {
    margin-top: 16rpx;
    font-size: 26rpx;
  }
  .info-card {
    background-color: #f8f8f8;
    border-radius: 16rpx;
    padding: 24rpx;
    margin-bottom: 24rpx;
  }
  .info-title {
    font-size: 30rpx;
    font-weight: bold;
    margin-bottom: 16rpx;
  }
  .info-item {
    font-size: 26rpx;
    color: #555555;
    padding: 6rpx 0;
  }
</style>
