/// アプリ全体の定数定義
library;

/// 対応画像形式 (設計書 §5.5)
const kSupportedExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
  'heic',
  'heif',
  'avif',
};

/// サムネイルサイズ (設計書 §11.2)
const kThumbnailSize = 256;

/// プリフェッチ枚数 (設計書 §12.4)
const kPrefetchCount = 20;

/// デフォルトキャッシュ上限 (500MB)
const kDefaultCacheSizeBytes = 500 * 1024 * 1024;

/// 最小キャッシュ上限 (100MB)
const kMinCacheSizeBytes = 100 * 1024 * 1024;

/// 最大キャッシュ上限 (2GB)
const kMaxCacheSizeBytes = 2 * 1024 * 1024 * 1024;

/// デフォルトグリッド列数
const kDefaultGridColumns = 4;

/// 列数レスポンシブ閾値
/// スマートフォン縦: 3〜4列、横: 5〜6列、タブレット: 5〜8列、Windows: 4〜10列
const kGridBreakpointPhone = 600.0;
const kGridBreakpointTablet = 960.0;

/// USB自動リトライ間隔（秒）
const kStorageRetryIntervalSeconds = 3;

/// アプリ名
const kAppName = 'Pictana';
