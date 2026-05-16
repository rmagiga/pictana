/// ナビゲーション境界判定の純粋関数。
///
/// [currentIndex] と [totalCount] を受け取り、
/// (canGoPrevious, canGoNext) のタプルを返す。
///
/// - totalCount <= 1 の場合は (false, false) を返す
/// - currentIndex == 0 の場合は canGoPrevious == false
/// - currentIndex == totalCount - 1 の場合は canGoNext == false
(bool, bool) navigationBounds(int currentIndex, int totalCount) {
  if (totalCount <= 1) return (false, false);
  return (currentIndex > 0, currentIndex < totalCount - 1);
}
