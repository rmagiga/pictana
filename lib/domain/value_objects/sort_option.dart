/// ソートオプション Value Object (設計書 §5.3, §18.3)
library;

/// ソート基準
enum SortField {
  name('名前'),
  date('日付'),
  size('サイズ'),
  type('種類');

  const SortField(this.label);
  final String label;
}

/// ソート方向
enum SortDirection {
  ascending('昇順'),
  descending('降順');

  const SortDirection(this.label);
  final String label;
}

/// ソートオプション
class SortOption {
  const SortOption({
    this.field = SortField.name,
    this.direction = SortDirection.ascending,
  });

  final SortField field;
  final SortDirection direction;

  /// デフォルト: 名前 昇順 (設計書 §18.3)
  static const defaultOption = SortOption();

  bool get isAscending => direction == SortDirection.ascending;

  /// 方向を反転したオプションを返す
  SortOption toggleDirection() => SortOption(
        field: field,
        direction: isAscending ? SortDirection.descending : SortDirection.ascending,
      );

  /// フィールドを変更したオプションを返す
  SortOption withField(SortField newField) => SortOption(
        field: newField,
        direction: SortDirection.ascending,
      );

  String get displayLabel => '${field.label} ${direction == SortDirection.ascending ? '▲' : '▼'}';

  @override
  bool operator ==(Object other) =>
      other is SortOption && field == other.field && direction == other.direction;

  @override
  int get hashCode => Object.hash(field, direction);

  @override
  String toString() => 'SortOption(field: $field, direction: $direction)';
}
