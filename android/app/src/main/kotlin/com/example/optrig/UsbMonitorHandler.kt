package com.example.optrig

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel

/// EventChannel ハンドラ — USB 接続/切断イベントの配信
/// ACTION_MEDIA_REMOVED, ACTION_MEDIA_UNMOUNTED, ACTION_MEDIA_MOUNTED を監視し、
/// Flutter 側に Map<String, Any> 形式でイベントを通知する。
/// EventChannel エラー時は 5 秒以内に BroadcastReceiver を再登録する。
class UsbMonitorHandler(
    private val context: Context
) : EventChannel.StreamHandler {

    companion object {
        private const val TAG = "UsbMonitorHandler"
        /// 再登録までの遅延時間（ミリ秒）
        private const val REREGISTER_DELAY_MS = 5000L
    }

    private var receiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var reregisterRunnable: Runnable? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerReceiver()
    }

    override fun onCancel(arguments: Any?) {
        unregisterReceiver()
        cancelPendingReregister()
        eventSink = null
    }

    /// BroadcastReceiver を登録し、USB メディアイベントの監視を開始する
    private fun registerReceiver() {
        // 既存のレシーバーがあれば先に解除
        unregisterReceiver()

        val intentFilter = IntentFilter().apply {
            addAction(Intent.ACTION_MEDIA_REMOVED)
            addAction(Intent.ACTION_MEDIA_UNMOUNTED)
            addAction(Intent.ACTION_MEDIA_MOUNTED)
            // メディアイベントには data スキームが必要
            addDataScheme("file")
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                try {
                    if (intent == null) return

                    val mountPath = intent.data?.path ?: ""
                    val volumeId = extractVolumeId(mountPath)
                    val eventType = when (intent.action) {
                        Intent.ACTION_MEDIA_MOUNTED -> "connected"
                        Intent.ACTION_MEDIA_REMOVED,
                        Intent.ACTION_MEDIA_UNMOUNTED -> "disconnected"
                        else -> return
                    }

                    val eventMap = mapOf<String, Any>(
                        "event" to eventType,
                        "volumeId" to volumeId,
                        "mountPath" to mountPath
                    )

                    eventSink?.success(eventMap)
                } catch (e: Exception) {
                    Log.e(TAG, "onReceive でエラー発生、再登録をスケジュール", e)
                    scheduleReregister()
                }
            }
        }

        try {
            // Android 14+ (API 34) では RECEIVER_EXPORTED フラグが必要
            context.registerReceiver(
                receiver,
                intentFilter,
                Context.RECEIVER_EXPORTED
            )
        } catch (e: Exception) {
            Log.e(TAG, "BroadcastReceiver 登録失敗、再登録をスケジュール", e)
            receiver = null
            scheduleReregister()
        }
    }

    /// BroadcastReceiver を解除する
    private fun unregisterReceiver() {
        receiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
                // 既に解除済みの場合は無視
                Log.w(TAG, "BroadcastReceiver は既に解除済み", e)
            }
        }
        receiver = null
    }

    /// 5 秒後に BroadcastReceiver を再登録するようスケジュールする
    /// （Requirement 9.5: EventChannel エラー時の再登録ロジック）
    private fun scheduleReregister() {
        // 既にスケジュール済みの場合はキャンセルして再スケジュール
        cancelPendingReregister()

        // eventSink が null の場合（onCancel 済み）は再登録しない
        if (eventSink == null) return

        reregisterRunnable = Runnable {
            Log.i(TAG, "BroadcastReceiver を再登録")
            reregisterRunnable = null
            if (eventSink != null) {
                registerReceiver()
            }
        }
        handler.postDelayed(reregisterRunnable!!, REREGISTER_DELAY_MS)
    }

    /// 保留中の再登録タスクをキャンセルする
    private fun cancelPendingReregister() {
        reregisterRunnable?.let {
            handler.removeCallbacks(it)
        }
        reregisterRunnable = null
    }

    /// マウントパスからボリューム ID を抽出する
    /// 例: "/storage/usb0" → "usb0", "/storage/1234-5678" → "1234-5678"
    private fun extractVolumeId(mountPath: String): String {
        if (mountPath.isEmpty()) return ""
        // マウントパスの最後のセグメントをボリューム ID として使用
        return mountPath.trimEnd('/').substringAfterLast('/')
    }
}
