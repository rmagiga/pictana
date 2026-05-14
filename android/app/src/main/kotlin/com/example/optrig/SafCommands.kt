package com.example.optrig

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Size
import androidx.documentfile.provider.DocumentFile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.io.ByteArrayOutputStream

/// SAF 個別操作の実装
/// すべての I/O 操作は Dispatchers.IO で実行する
object SafCommands {

    /// フォルダ選択 Intent を起動し、選択結果を返す
    /// キャンセル時は null を返す
    /// 無効な URI の場合は IllegalArgumentException をスロー
    suspend fun selectFolder(activity: Activity): Map<String, Any>? {
        // MainActivity にキャストして ActivityResultLauncher にアクセス
        val mainActivity = activity as MainActivity

        // suspendCancellableCoroutine で Activity Result を待つ
        val uri = suspendCancellableCoroutine { continuation ->
            mainActivity.pendingFolderSelectContinuation = continuation
            continuation.invokeOnCancellation {
                mainActivity.pendingFolderSelectContinuation = null
            }
            // ACTION_OPEN_DOCUMENT_TREE を起動
            mainActivity.openDocumentTreeLauncher.launch(null)
        }

        // キャンセル時: null を返す
        if (uri == null) {
            return null
        }

        // URI の有効性を検証
        val treeDocumentId = try {
            DocumentsContract.getTreeDocumentId(uri)
        } catch (e: Exception) {
            throw IllegalArgumentException("Invalid document tree URI: $uri", e)
        }

        if (treeDocumentId.isNullOrEmpty()) {
            throw IllegalArgumentException("Invalid document tree URI: tree document ID is empty")
        }

        // takePersistableUriPermission — 実際に付与されたフラグのみで永続化する
        // USB OTG 等では WRITE 権限が付与されない場合があるため、
        // READ+WRITE で試行し、失敗したら READ のみで再試行する
        val contentResolver = activity.contentResolver
        val rwFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        try {
            contentResolver.takePersistableUriPermission(uri, rwFlags)
        } catch (e: SecurityException) {
            // WRITE 権限がない場合は READ のみで永続化
            val rFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            contentResolver.takePersistableUriPermission(uri, rFlags)
        }

        // DocumentFile を使って表示名を取得
        val documentFile = DocumentFile.fromTreeUri(activity, uri)
        val displayName = documentFile?.name ?: treeDocumentId.substringAfterLast('/')

        // ドキュメント URI を構築
        val documentUri = DocumentsContract.buildDocumentUriUsingTree(
            uri, treeDocumentId
        )

        // FolderEntry Map を返す
        return mapOf(
            "documentId" to treeDocumentId,
            "name" to displayName,
            "uri" to documentUri.toString(),
            "treeUri" to uri.toString()
        )
    }

    /// マウント済みストレージボリュームを列挙し、StorageRoot Map のリストを返す
    /// 3 秒タイムアウトを設定し、超過時は例外をスロー
    suspend fun getStorageRoots(context: Context): List<Map<String, Any>> =
        withTimeout(3000L) {
            withContext(Dispatchers.IO) {
                val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
                val volumes: List<StorageVolume> = storageManager.storageVolumes

                val roots = volumes.map { volume ->
                    val volumeId = volume.uuid ?: "primary"
                    val name = volume.getDescription(context)
                    val type = if (volume.isRemovable) "usb" else "internal"
                    val isConnected = volume.state == Environment.MEDIA_MOUNTED
                    // content:// URI をボリュームのドキュメントツリーとして構築
                    val uri = "content://com.android.externalstorage.documents/tree/${volumeId}%3A"

                    mapOf<String, Any>(
                        "id" to uri,
                        "name" to name,
                        "type" to type,
                        "uri" to uri,
                        "isConnected" to isConnected
                    )
                }

                // 内部ストレージ優先 → 名前昇順でソート
                roots.sortedWith(compareBy<Map<String, Any>> { it["type"] as String != "internal" }
                    .thenBy { it["name"] as String })
            }
        }

    /// フォルダ列挙時に取得するカラム
    private val FOLDER_PROJECTION = arrayOf(
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        DocumentsContract.Document.COLUMN_MIME_TYPE,
    )

    /// ディレクトリを示す MIME type
    private const val MIME_TYPE_DIRECTORY = "vnd.android.document/directory"

    /// 指定フォルダの子フォルダを列挙する
    /// documentId が null の場合はツリールートの子フォルダを返す
    /// SecurityException, FileNotFoundException はそのまま伝播させる
    suspend fun getChildFolders(
        context: Context,
        treeUri: Uri,
        documentId: String?
    ): List<Map<String, Any>> =
        withContext(Dispatchers.IO) {
            // documentId が null の場合はツリールートのドキュメント ID を取得
            val docId = documentId ?: DocumentsContract.getTreeDocumentId(treeUri)

            // 子ドキュメント URI を構築
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, docId)

            val folders = mutableListOf<Map<String, Any>>()

            context.contentResolver.query(
                childrenUri,
                FOLDER_PROJECTION,
                null,
                null,
                null
            )?.use { cursor ->
                val idIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)

                while (cursor.moveToNext()) {
                    val mimeType = cursor.getString(mimeIndex)

                    // ディレクトリ MIME type でフィルタリング
                    if (mimeType != MIME_TYPE_DIRECTORY) continue

                    val childDocId = cursor.getString(idIndex)
                    val name = cursor.getString(nameIndex)

                    // 個別ドキュメント URI を構築
                    val childUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, childDocId)

                    folders.add(mapOf(
                        "documentId" to childDocId,
                        "name" to name,
                        "uri" to childUri.toString(),
                        "treeUri" to treeUri.toString(),
                        "parentDocumentId" to docId
                    ))
                }
            }

            // 名前のケース非依存昇順ソート
            folders.sortWith(compareBy(String.CASE_INSENSITIVE_ORDER) { it["name"] as String })

            folders
        }

    /// 画像列挙時に取得するカラム（最小限）
    private val IMAGE_PROJECTION = arrayOf(
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        DocumentsContract.Document.COLUMN_MIME_TYPE,
        DocumentsContract.Document.COLUMN_SIZE,
        DocumentsContract.Document.COLUMN_LAST_MODIFIED,
    )

    /// サポートする画像 MIME type
    private val SUPPORTED_IMAGE_MIME_TYPES = setOf(
        "image/jpeg", "image/png", "image/webp",
        "image/gif", "image/heic", "image/heif", "image/avif",
    )

    /// 指定フォルダ内の画像ファイルを列挙する（バッチ対応）
    /// offset/limit でページネーションを行う
    /// 個別ファイル読み取りエラーはスキップして継続
    suspend fun getImages(
        context: Context,
        treeUri: Uri,
        documentId: String,
        offset: Int,
        limit: Int
    ): List<Map<String, Any>> =
        withContext(Dispatchers.IO) {
            // 子ドキュメント URI を構築
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId)

            val images = mutableListOf<Map<String, Any>>()

            context.contentResolver.query(
                childrenUri,
                IMAGE_PROJECTION,
                null,
                null,
                null
            )?.use { cursor ->
                val idIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
                val sizeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_SIZE)
                val lastModifiedIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_LAST_MODIFIED)

                // MIME type フィルタリングしながら offset 位置まで移動
                // SAF の Cursor はフィルタリング前の全件を含むため、
                // 手動でフィルタリングしつつ offset/limit を適用する
                var skipped = 0
                var collected = 0

                while (cursor.moveToNext() && collected < limit) {
                    try {
                        val mimeType = cursor.getString(mimeIndex)

                        // サポート対象の画像 MIME type でフィルタリング
                        if (mimeType == null || mimeType !in SUPPORTED_IMAGE_MIME_TYPES) continue

                        // offset 分スキップ
                        if (skipped < offset) {
                            skipped++
                            continue
                        }

                        val childDocId = cursor.getString(idIndex)
                        val name = cursor.getString(nameIndex) ?: ""
                        val size = if (cursor.isNull(sizeIndex)) 0L else cursor.getLong(sizeIndex)
                        val lastModified = if (cursor.isNull(lastModifiedIndex)) 0L else cursor.getLong(lastModifiedIndex)

                        // ドキュメント URI を構築
                        val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, childDocId)

                        // 拡張子を抽出（小文字、ドットなし）
                        val extension = name.substringAfterLast('.', "").lowercase()

                        images.add(mapOf(
                            "documentId" to childDocId,
                            "name" to name,
                            "extension" to extension,
                            "uri" to docUri.toString(),
                            "mimeType" to mimeType,
                            "size" to size,
                            "lastModified" to lastModified
                        ))

                        collected++
                    } catch (e: Exception) {
                        // 個別ファイル読み取りエラーはスキップして継続
                        continue
                    }
                }
            }

            images
        }

    /// 画像バイトデータを ContentResolver.openInputStream で読み込む（<= 10MB）
    /// 100MB 超の場合は OutOfMemoryError をスロー
    /// 30 秒タイムアウト付き
    suspend fun getImageBytes(context: Context, contentUri: Uri): ByteArray =
        withTimeout(30_000L) {
            withContext(Dispatchers.IO) {
                val stream = context.contentResolver.openInputStream(contentUri)
                    ?: throw java.io.FileNotFoundException("Cannot open input stream: $contentUri")

                val bytes = stream.use { it.readBytes() }

                // 100MB 超チェック
                if (bytes.size > 100 * 1024 * 1024) {
                    throw OutOfMemoryError("File size exceeds 100MB limit: ${bytes.size} bytes")
                }

                bytes
            }
        }

    /// 画像バイトデータを一時ファイルに書き出してパスを返す（> 10MB）
    /// 100MB 超の場合は OutOfMemoryError をスロー
    /// 30 秒タイムアウト付き
    suspend fun getImageBytesViaFile(context: Context, contentUri: Uri): String =
        withTimeout(30_000L) {
            withContext(Dispatchers.IO) {
                // ファイルサイズを事前チェック
                val fileSize = context.contentResolver.query(
                    contentUri,
                    arrayOf(DocumentsContract.Document.COLUMN_SIZE),
                    null,
                    null,
                    null
                )?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val sizeIndex = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_SIZE)
                        cursor.getLong(sizeIndex)
                    } else {
                        null
                    }
                }

                // 100MB 超チェック
                if (fileSize != null && fileSize > 100L * 1024L * 1024L) {
                    throw OutOfMemoryError("File size exceeds 100MB limit: $fileSize bytes")
                }

                // 一時ファイルディレクトリを作成
                val tmpDir = java.io.File(context.cacheDir, "tmp_images")
                if (!tmpDir.exists()) {
                    tmpDir.mkdirs()
                }

                // 一時ファイルを作成
                val tmpFile = java.io.File.createTempFile("tmp_", ".bin", tmpDir)

                try {
                    val inputStream = context.contentResolver.openInputStream(contentUri)
                        ?: throw java.io.FileNotFoundException("Cannot open input stream: $contentUri")

                    // バッファ付きストリームでコピー
                    inputStream.buffered().use { input ->
                        tmpFile.outputStream().buffered().use { output ->
                            input.copyTo(output)
                        }
                    }

                    tmpFile.absolutePath
                } catch (e: Exception) {
                    // エラー時は一時ファイルを削除
                    tmpFile.delete()
                    throw e
                }
            }
        }

    /// サムネイルを取得する（loadThumbnail + BitmapFactory フォールバック）
    /// 生成失敗時は null を返す（例外を投げない）
    suspend fun getThumbnail(
        context: Context,
        contentUri: Uri,
        width: Int,
        height: Int
    ): ByteArray? =
        withContext(Dispatchers.IO) {
            val bitmap = loadThumbnailPrimary(context, contentUri, width, height)
                ?: loadThumbnailFallback(context, contentUri, width, height)
                ?: return@withContext null

            try {
                val outputStream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
                outputStream.toByteArray()
            } catch (_: Exception) {
                null
            } finally {
                bitmap.recycle()
            }
        }

    /// ContentResolver.loadThumbnail を使用したサムネイル取得（プライマリパス）
    private fun loadThumbnailPrimary(
        context: Context,
        contentUri: Uri,
        width: Int,
        height: Int
    ): Bitmap? {
        return try {
            context.contentResolver.loadThumbnail(contentUri, Size(width, height), null)
        } catch (_: Exception) {
            null
        }
    }

    /// BitmapFactory + createScaledBitmap によるフォールバックサムネイル生成
    /// アスペクト比を維持してリサイズする
    private fun loadThumbnailFallback(
        context: Context,
        contentUri: Uri,
        width: Int,
        height: Int
    ): Bitmap? {
        var original: Bitmap? = null
        try {
            val inputStream = context.contentResolver.openInputStream(contentUri)
                ?: return null
            original = inputStream.use { stream ->
                BitmapFactory.decodeStream(stream)
            } ?: return null

            // アスペクト比を維持してスケール計算
            val originalWidth = original.width
            val originalHeight = original.height
            val scale = minOf(
                width.toFloat() / originalWidth.toFloat(),
                height.toFloat() / originalHeight.toFloat()
            )
            val scaledWidth = (originalWidth * scale).toInt().coerceAtLeast(1)
            val scaledHeight = (originalHeight * scale).toInt().coerceAtLeast(1)

            val scaled = Bitmap.createScaledBitmap(original, scaledWidth, scaledHeight, true)
            // createScaledBitmap が同じインスタンスを返す場合はリサイクルしない
            if (scaled !== original) {
                original.recycle()
            }
            return scaled
        } catch (_: Exception) {
            original?.recycle()
            return null
        }
    }

    /// デフォルト画像フォルダ（DCIM > Pictures）を検出する
    /// MediaStore クエリで DCIM/Pictures に画像が存在するか確認し、
    /// 優先順位 DCIM > Pictures で最初に見つかったフォルダを返す
    /// 存在しない場合・アクセス不可の場合は null を返す
    @Suppress("DEPRECATION")
    suspend fun getDefaultImageFolder(context: Context): Map<String, Any>? =
        withContext(Dispatchers.IO) {
            try {
                // 優先順位順にチェックするフォルダ名リスト
                val candidates = listOf("DCIM", "Pictures")

                for (folderName in candidates) {
                    if (hasImagesInFolder(context, folderName)) {
                        // SAF 互換の content:// URI を構築
                        val documentId = "primary:$folderName"
                        val treeUri = "content://com.android.externalstorage.documents/tree/primary%3A"
                        val documentUri = "content://com.android.externalstorage.documents/tree/primary%3A/document/primary%3A$folderName"

                        return@withContext mapOf(
                            "documentId" to documentId,
                            "name" to folderName,
                            "uri" to documentUri,
                            "treeUri" to treeUri
                        )
                    }
                }

                // どちらも見つからない場合
                null
            } catch (_: Exception) {
                // アクセス不可・エラー時は null を返す
                null
            }
        }

    /// MediaStore クエリで指定フォルダ内に画像が存在するか確認する
    /// DATA カラム（deprecated だが MediaStore クエリでのパス確認には使用可能）を使用
    @Suppress("DEPRECATION")
    private fun hasImagesInFolder(context: Context, folderName: String): Boolean {
        val projection = arrayOf(MediaStore.Images.Media._ID)
        val selection = "${MediaStore.Images.Media.DATA} LIKE ?"
        val selectionArgs = arrayOf("%/$folderName/%")

        return try {
            context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null
            )?.use { cursor ->
                cursor.count > 0
            } ?: false
        } catch (_: Exception) {
            false
        }
    }
}
