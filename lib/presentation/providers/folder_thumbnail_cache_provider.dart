/// フォルダサムネイルのメモリキャッシュ Provider
///
/// LRU（Least Recently Used）方式でサムネイルバイト列を
/// 最大50件までメモリ上にキャッシュする。
/// 画面再表示時にファイル I/O を発生させず、即座にサムネイルを返す。
library;

import 'dart:collection';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_thumbnail_cache_provider.g.dart';

/// フォルダサムネイルのメモリキャッシュを管理する Provider
///
/// [LinkedHashMap] を使用した LRU キャッシュで、
/// アクセス時にエントリを末尾に移動し、上限超過時は
/// 先頭（最も古い）エントリを削除する。
@Riverpod(keepAlive: true)
class FolderThumbnailCache extends _$FolderThumbnailCache {
  /// キャッシュ上限
  static const int maxCacheSize = 50;

  /// LRU 順序を保持する内部キャッシュ
  final LinkedHashMap<String, Uint8List> _cache =
      LinkedHashMap<String, Uint8List>();

  @override
  Map<String, Uint8List> build() => {};

  /// キャッシュからサムネイルを取得する
  ///
  /// キャッシュヒット時はエントリを末尾に移動（最近使用済みとしてマーク）し、
  /// バイト列を返す。キャッシュミス時は null を返す。
  Uint8List? get(String folderUri) {
    final bytes = _cache.remove(folderUri);
    if (bytes != null) {
      // 末尾に再挿入して最近使用済みとしてマーク
      _cache[folderUri] = bytes;
      state = Map.of(_cache);
    }
    return bytes;
  }

  /// サムネイルをキャッシュに追加する（LRU 方式で上限管理）
  ///
  /// 既存キーの場合は削除して末尾に再挿入する。
  /// キャッシュが上限に達している場合は、先頭（最も古い）エントリを削除する。
  void put(String folderUri, Uint8List bytes) {
    // 既存エントリがあれば削除（末尾に再挿入するため）
    _cache.remove(folderUri);

    // 上限に達している場合は先頭（最も古い）を削除
    if (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }

    // 末尾に追加
    _cache[folderUri] = bytes;
    state = Map.of(_cache);
  }

  /// キャッシュをクリアする
  void clear() {
    _cache.clear();
    state = {};
  }
}
