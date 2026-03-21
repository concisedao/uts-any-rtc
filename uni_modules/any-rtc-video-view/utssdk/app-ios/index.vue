<template>
  <view></view>
</template>

<script lang="uts">
  import { UIView } from "UIKit"
  import { setLocalVideoCanvas, setRemoteVideoCanvas } from '@/uni_modules/uts-any-rtc'

  export default {
    name: "any-rtc-video-view",
    props: {
      uid: {
        type: String,
        default: ''
      },
      roomId: {
        type: String,
        default: ''
      },
      renderMode: {
        type: String,
        default: 'hidden'
      },
      mirrorType: {
        type: String,
        default: 'none'
      },
      streamIndex: {
        type: String,
        default: 'main'
      }
    },
    data() {
      return {
        isCanvasBound: false as boolean
      }
    },
    watch: {
      uid: {
        handler(newValue : string, oldValue : string) {
          this.rebindCanvas()
        },
        immediate: false
      },
      roomId: {
        handler(newValue : string, oldValue : string) {
          this.rebindCanvas()
        },
        immediate: false
      },
      renderMode: {
        handler(newValue : string, oldValue : string) {
          this.rebindCanvas()
        },
        immediate: false
      },
      mirrorType: {
        handler(newValue : string, oldValue : string) {
          this.rebindCanvas()
        },
        immediate: false
      },
      streamIndex: {
        handler(newValue : string, oldValue : string) {
          this.rebindCanvas()
        },
        immediate: false
      }
    },
    expose: ['bindCanvas', 'unbindCanvas'],
    methods: {
      bindCanvas() {
        const nativeView = this.$el as UIView

        if (this.uid == '' || this.uid == null) {
          setLocalVideoCanvas({
            uid: '',
            view: nativeView,
            renderMode: this.renderMode,
            mirrorType: this.mirrorType,
            streamIndex: this.streamIndex
          })
        } else {
          setRemoteVideoCanvas({
            uid: this.uid,
            roomId: this.roomId,
            view: nativeView,
            renderMode: this.renderMode,
            mirrorType: this.mirrorType,
            streamIndex: this.streamIndex
          })
        }

        this.isCanvasBound = true
      },
      unbindCanvas() {
        if (!this.isCanvasBound) return

        if (this.uid == '' || this.uid == null) {
          setLocalVideoCanvas({
            uid: '',
            streamIndex: this.streamIndex
          })
        } else {
          setRemoteVideoCanvas({
            uid: this.uid,
            roomId: this.roomId,
            streamIndex: this.streamIndex
          })
        }

        this.isCanvasBound = false
      },
      rebindCanvas() {
        this.unbindCanvas()
        this.bindCanvas()
      }
    },
    NVLoad() : UIView {
      return new UIView()
    },
    NVLoaded() {
      this.bindCanvas()
    },
    NVBeforeUnload() {
      this.unbindCanvas()
    }
  }
</script>

<style>
</style>
