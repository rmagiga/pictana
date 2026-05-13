package com.example.optrig

import android.net.Uri
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellableContinuation

/// FlutterActivity を拡張し、SAF 用 MethodChannel と USB 監視用 EventChannel を登録する
class MainActivity : FlutterActivity() {

    companion object {
        private const val SAF_CHANNEL = "com.example.optrig/saf"
        private const val USB_EVENT_CHANNEL = "com.example.optrig/saf/usb"
    }

    /// フォルダ選択結果を待つ continuation（SafCommands.selectFolder から設定される）
    var pendingFolderSelectContinuation: CancellableContinuation<Uri?>? = null

    /// ACTION_OPEN_DOCUMENT_TREE 用の ActivityResultLauncher
    lateinit var openDocumentTreeLauncher: ActivityResultLauncher<Uri?>

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        // ActivityResultLauncher は onCreate で登録する必要がある
        openDocumentTreeLauncher = registerForActivityResult(
            ActivityResultContracts.OpenDocumentTree()
        ) { uri: Uri? ->
            // 結果を pending continuation に通知
            val continuation = pendingFolderSelectContinuation
            pendingFolderSelectContinuation = null
            continuation?.resumeWith(Result.success(uri))
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // SAF MethodChannel を登録
        val safHandler = SafMethodHandler(this, applicationContext)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAF_CHANNEL
        ).setMethodCallHandler(safHandler)

        // USB 監視 EventChannel を登録
        val usbMonitorHandler = UsbMonitorHandler(applicationContext)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            USB_EVENT_CHANNEL
        ).setStreamHandler(usbMonitorHandler)
    }
}
