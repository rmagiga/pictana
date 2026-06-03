import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/image_size_parser.dart';
import '../../../domain/entities/image_entry.dart';
import '../../providers/repository_providers.dart';

part 'image_size_resolve_usecase.g.dart';

@riverpod
class ImageSizeResolveUseCase extends _$ImageSizeResolveUseCase {
  @override
  ImageSizeResolveUseCase build() {
    return this;
  }

  /// 解像度が未取得の画像のサイズを非同期でパースし、DBに書き込む
  Future<void> execute(List<ImageEntry> images) async {
    final unresolved = images.where((img) => img.width == null || img.height == null).toList();
    if (unresolved.isEmpty) return;

    final db = ref.read(appDatabaseProvider);

    // 大量の画像が未解決の場合でも、一度に並行処理する上限を設定してOOMやリソース食い潰しを防ぐ
    const concurrencyLimit = 5;
    for (var i = 0; i < unresolved.length; i += concurrencyLimit) {
      final chunk = unresolved.sublist(
        i,
        i + concurrencyLimit > unresolved.length ? unresolved.length : i + concurrencyLimit,
      );

      await Future.wait(chunk.map((image) async {
        try {
          // ヘッダーパースは非同期I/Oメインで極めて軽量なため、Isolateを使わず直接実行する
          final size = await ImageSizeParser.parseFile(image.uri);
          if (size != null) {
            await db.updateImageSize(
              entryId: image.id.rawValue,
              width: size.width,
              height: size.height,
            );
          } else {
            // 解析失敗（非対応形式や破損）の場合もダミー値を書き込んで再スキャンを防ぐ
            await db.updateImageSize(
              entryId: image.id.rawValue,
              width: -1,
              height: -1,
            );
          }
        } catch (_) {
          // 解析失敗（破損ファイルなど）は無視して次の処理へ
        }
      }));
    }
  }
}
