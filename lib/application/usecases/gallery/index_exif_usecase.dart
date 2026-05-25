import 'dart:async';

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/exif_processor.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../infrastructure/database/app_database.dart';

/// フォルダ内の画像に対して非同期で EXIF メタデータを抽出・インデックス化するユースケース
class IndexExifUseCase {
  const IndexExifUseCase({
    required AppDatabase database,
    required ImageRepository imageRepository,
    required ExifProcessor exifProcessor,
  })  : _db = database,
        _imageRepository = imageRepository,
        _exifProcessor = exifProcessor;

  final AppDatabase _db;
  final ImageRepository _imageRepository;
  final ExifProcessor _exifProcessor;

  /// 非同期で EXIF インデックス処理を実行する
  ///
  /// 指定したフォルダ内の画像のうち、EXIF 列が未取得のものをスキャンし、
  /// バックグラウンドで順次パースしてデータベースを更新する。
  Future<void> execute(FolderEntry folder) async {
    try {
      final missingExifImages = await _db.getImagesMissingExif(folder.uri);
      if (missingExifImages.isEmpty) {
        return;
      }

      appLogger.d(
        'EXIF インデックス処理開始: ${folder.name} (対象: ${missingExifImages.length} 枚)',
      );

      // 非同期で1枚ずつ処理する (UIスレッドを占有しないよう遅延を入れつつ処理)
      // I/O を伴うため、一括処理ではなく逐次非同期実行にする
      _runIndexing(missingExifImages);
    } catch (e, st) {
      appLogger.w('EXIF インデックス処理起動に失敗しました', error: e, stackTrace: st);
    }
  }

  /// バックグラウンドで順次インデックス処理を実行する (Fire and Forget)
  Future<void> _runIndexing(List<ImageTableData> images) async {
    for (final dbImage in images) {
      try {
        final entry = _toImageEntry(dbImage);

        // 画像のバイトデータを読み込む (非同期)
        final bytes = await _imageRepository.getImageBytes(entry);
        if (bytes.isEmpty) continue;

        // EXIF を解析 (非同期)
        final exif = await _exifProcessor.extractMetadata(bytes);

        // 解析できた場合に DB を更新 (解析に失敗して空の場合でも、
        // 毎回解析が走るのを防ぐためにダミー日付やフラグを入れるなど工夫が必要だが、
        // 今回は撮影日時が未取得でも updated とする。
        // ここでは撮影日時、カメラ、GPS情報のいずれかが取れれば、DB を更新する。
        // パースを試みた証跡として、どれも null でも「パース済み」とするため、
        // 撮影日時が null なら Epoch 時刻 (DateTime.fromMillisecondsSinceEpoch(0)) 等を
        // 代入しておくと、再パースを防ぐことができる。
        final recordDateTime = exif.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);

        await _db.updateExif(
          entryId: dbImage.entryId,
          exifDateTime: recordDateTime,
          exifCamera: exif.camera ?? 'Unknown',
          exifGpsLatitude: exif.latitude,
          exifGpsLongitude: exif.longitude,
        );

        // UIスレッドを保護するため、1件ごとに少し待機する
        await Future<void>.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        // 個別ファイルのエラー (破損画像等) はログ出力してスキップ
        appLogger.w('個別画像の EXIF パース失敗: ${dbImage.uri}', error: e);
        // 再試行を防ぐため、失敗時もダミー値で更新しておく
        try {
          await _db.updateExif(
            entryId: dbImage.entryId,
            exifDateTime: DateTime.fromMillisecondsSinceEpoch(0),
            exifCamera: 'Failed',
          );
        } catch (_) {}
      }
    }
    appLogger.d('EXIF インデックス処理完了しました。');
  }

  /// ImageTableData から ImageEntry への簡易マッパー
  ImageEntry _toImageEntry(ImageTableData data) {
    final isAndroid = data.uri.startsWith('content://');
    return ImageEntry(
      id: isAndroid ? EntryId.android(data.entryId) : EntryId.windows(data.uri),
      name: data.name,
      extension: data.extension,
      uri: data.uri,
      mimeType: ImageMimeType.values.byName(data.mimeType),
      size: data.size,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(data.modified),
    );
  }
}
