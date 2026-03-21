<template>
  <view style="background-color: transparent;"></view>
</template>

<script lang="uts">
  import TextureView from 'android.view.TextureView'
  import { setLocalVideoCanvas, setRemoteVideoCanvas, SetLocalVideoCanvasOptions, SetRemoteVideoCanvasOptions } from '@/uni_modules/uts-any-rtc'

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
        const nativeView = this.$el as TextureView

        if (this.uid == '' || this.uid == null) {
          setLocalVideoCanvas({
            uid: '',
            view: nativeView,
            renderMode: this.renderMode,
            mirrorType: this.mirrorType,
            streamIndex: this.streamIndex
          } as SetLocalVideoCanvasOptions)
        } else {
          setRemoteVideoCanvas({
            uid: this.uid,
            roomId: this.roomId,
            view: nativeView,
            renderMode: this.renderMode,
            mirrorType: this.mirrorType,
            streamIndex: this.streamIndex
          } as SetRemoteVideoCanvasOptions)
        }

        this.isCanvasBound = true
      },
      unbindCanvas() {
        if (!this.isCanvasBound) return

        if (this.uid == '' || this.uid == null) {
          setLocalVideoCanvas({
            uid: '',
            streamIndex: this.streamIndex
          } as SetLocalVideoCanvasOptions)
        } else {
          setRemoteVideoCanvas({
            uid: this.uid,
            roomId: this.roomId,
            streamIndex: this.streamIndex
          } as SetRemoteVideoCanvasOptions)
        }

        this.isCanvasBound = false
      },
      rebindCanvas() {
        this.unbindCanvas()
        this.bindCanvas()
      }
    },
    NVLoad() : TextureView {
      return new TextureView($androidContext!)
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
