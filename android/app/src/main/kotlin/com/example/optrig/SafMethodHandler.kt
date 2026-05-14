package com.example.optrig

import android.content.Context
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/// MethodChannel ハンドラ — SAF 操作のディスパッチ
/// 各メソッド呼び出しをコルーチンスコープ内で SafCommands に委譲する
class SafMethodHandler(
    private val activity: FlutterFragmentActivity,
    private val context: Context
) : MethodChannel.MethodCallHandler {

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            when (call.method) {
                "selectFolder" -> handleSelectFolder(call, result)
                "getStorageRoots" -> handleGetStorageRoots(result)
                "getChildFolders" -> handleGetChildFolders(call, result)
                "getImages" -> handleGetImages(call, result)
                "getImageBytes" -> handleGetImageBytes(call, result)
                "getImageBytesViaFile" -> handleGetImageBytesViaFile(call, result)
                "getThumbnail" -> handleGetThumbnail(call, result)
                "persistUriPermission" -> handlePersistUriPermission(call, result)
                "getPersistedUriPermissions" -> handleGetPersistedUriPermissions(result)
                "releaseUriPermission" -> handleReleaseUriPermission(call, result)
                "getDefaultImageFolder" -> handleGetDefaultImageFolder(result)
                else -> result.notImplemented()
            }
        }
    }

    private suspend fun handleSelectFolder(call: MethodCall, result: MethodChannel.Result) {
        try {
            val folderMap = SafCommands.selectFolder(activity)
            result.success(folderMap)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: IllegalArgumentException) {
            result.error("STORAGE_DISCONNECTED", "Invalid URI: ${e.message}", e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetStorageRoots(result: MethodChannel.Result) {
        try {
            val roots = SafCommands.getStorageRoots(context)
            result.success(roots)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: kotlinx.coroutines.TimeoutCancellationException) {
            result.error("STORAGE_DISCONNECTED", "Storage enumeration timed out: ${e.message}", e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetChildFolders(call: MethodCall, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(call.argument<String>("treeUri"))
            val documentId = call.argument<String>("documentId")
            val folders = SafCommands.getChildFolders(context, treeUri, documentId)
            result.success(folders)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: java.io.FileNotFoundException) {
            result.error("STORAGE_DISCONNECTED", e.message, e.stackTraceToString())
        } catch (e: IllegalArgumentException) {
            result.error("STORAGE_DISCONNECTED", "Invalid URI: ${e.message}", null)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetImages(call: MethodCall, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(call.argument<String>("treeUri"))
            val documentId = call.argument<String>("documentId")!!
            val offset = call.argument<Int>("offset") ?: 0
            val limit = call.argument<Int>("limit") ?: 50
            val images = SafCommands.getImages(context, treeUri, documentId, offset, limit)
            result.success(images)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: java.io.FileNotFoundException) {
            result.error("STORAGE_DISCONNECTED", e.message, e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetImageBytes(call: MethodCall, result: MethodChannel.Result) {
        try {
            val contentUri = Uri.parse(call.argument<String>("contentUri"))
            val bytes = SafCommands.getImageBytes(context, contentUri)
            result.success(bytes)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: java.io.FileNotFoundException) {
            result.error("STORAGE_DISCONNECTED", e.message, e.stackTraceToString())
        } catch (e: OutOfMemoryError) {
            result.error("OUT_OF_MEMORY", e.message, e.stackTraceToString())
        } catch (e: kotlinx.coroutines.TimeoutCancellationException) {
            result.error("STORAGE_DISCONNECTED", "Image read timed out: ${e.message}", e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetImageBytesViaFile(call: MethodCall, result: MethodChannel.Result) {
        try {
            val contentUri = Uri.parse(call.argument<String>("contentUri"))
            val filePath = SafCommands.getImageBytesViaFile(context, contentUri)
            result.success(filePath)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: java.io.FileNotFoundException) {
            result.error("STORAGE_DISCONNECTED", e.message, e.stackTraceToString())
        } catch (e: OutOfMemoryError) {
            result.error("OUT_OF_MEMORY", e.message, e.stackTraceToString())
        } catch (e: kotlinx.coroutines.TimeoutCancellationException) {
            result.error("STORAGE_DISCONNECTED", "Image file write timed out: ${e.message}", e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetThumbnail(call: MethodCall, result: MethodChannel.Result) {
        try {
            val contentUri = Uri.parse(call.argument<String>("contentUri"))
            val width = call.argument<Int>("width") ?: 256
            val height = call.argument<Int>("height") ?: 256
            val thumbnail = SafCommands.getThumbnail(context, contentUri, width, height)
            result.success(thumbnail)
        } catch (e: Exception) {
            // サムネイル生成失敗時は null を返す（例外を投げない）
            result.success(null)
        }
    }

    private suspend fun handlePersistUriPermission(call: MethodCall, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(call.argument<String>("uri"))
            val flags = android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    android.content.Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            context.contentResolver.takePersistableUriPermission(uri, flags)
            result.success(null)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetPersistedUriPermissions(result: MethodChannel.Result) {
        try {
            val permissions = context.contentResolver.persistedUriPermissions
            val uriStrings = permissions.map { it.uri.toString() }
            result.success(uriStrings)
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleReleaseUriPermission(call: MethodCall, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(call.argument<String>("uri"))
            val flags = android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    android.content.Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            context.contentResolver.releasePersistableUriPermission(uri, flags)
            result.success(null)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, e.stackTraceToString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", e.message, e.stackTraceToString())
        }
    }

    private suspend fun handleGetDefaultImageFolder(result: MethodChannel.Result) {
        try {
            val folderMap = SafCommands.getDefaultImageFolder(context)
            result.success(folderMap)
        } catch (e: Exception) {
            // デフォルトフォルダ検出失敗時は null を返す
            result.success(null)
        }
    }
}
