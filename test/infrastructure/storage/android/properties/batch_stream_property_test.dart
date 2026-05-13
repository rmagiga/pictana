/// Property 11: エラー耐性列挙
///
/// 画像ドキュメントリストの中に読み取り不可（I/O エラー、パーミッションエラー）の
/// エントリが含まれる場合、列挙結果には読み取り可能なエントリのみが含まれ、
/// 読み取り不可のエントリは除外され、Stream がエラーで中断されないことを検証する。
///
/// **Validates: Requirements 5.8**
@Tags(['android-saf', 'property-test'])
library;

import 'package:glados/glados.dart';

/// エラーフラグ付き画像エントリ
///
/// [hasError] が true の場合、I/O エラーやパーミッションエラーにより
/// 読み取り不可であることを示す。
class ImageDocumentWithError {
  const ImageDocumentWithError({
    required this.documentId,
    required this.name,
    required this.hasError,
  });

  /// ドキュメント ID
  final String documentId;

  /// ファイル名
  final String name;

  /// エラーフラグ（true = 読み取り不可）
  final bool hasError;

  @override
  String toString() =>
      'ImageDocumentWithError(documentId: $documentId, name: $name, hasError: $hasError)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageDocumentWithError &&
          documentId == other.documentId &&
          name == other.name &&
          hasError == other.hasError;

  @override
  int get hashCode => Object.hash(documentId, name, hasError);
}

/// エラー耐性列挙のフィルタリング関数
///
/// AndroidImageRepository.getImages() 内のエラー耐性ロジックと同等の純粋関数。
/// エラーフラグ付きエントリリストを受け取り、エラーのないエントリのみを返す。
/// エラーのあるエントリはスキップし、Stream を中断しない。
List<ImageDocumentWithError> filterErrorResilient(
  List<ImageDocumentWithError> documents,
) {
  final results = <ImageDocumentWithError>[];
  for (final doc in documents) {
    // エラーのあるエントリはスキップして継続（エラー耐性）
    if (doc.hasError) continue;
    results.add(doc);
  }
  return results;
}

/// ExploreConfig: 最低 100 回のイテレーション
final _exploreConfig = ExploreConfig(numRuns: 100, initialSize: 10, speed: 10);

/// エラーフラグ付き画像リストのジェネレータ
extension ErrorResilientGenerators on Any {
  /// ランダムな ImageDocumentWithError を生成するジェネレータ
  Generator<ImageDocumentWithError> get imageDocumentWithError => combine3(
    any.nonEmptyLetters,
    any.nonEmptyLetters,
    any.bool,
    (String docId, String name, bool hasError) => ImageDocumentWithError(
      documentId: 'primary:DCIM/$docId',
      name: '$name.jpg',
      hasError: hasError,
    ),
  );

  /// エラーフラグ付き画像リストを生成するジェネレータ
  Generator<List<ImageDocumentWithError>> get imageDocumentListWithErrors =>
      any.list(any.imageDocumentWithError);
}

void main() {
  group('Feature: android-saf, Property 11: エラー耐性列挙', () {
    Glados(any.imageDocumentListWithErrors, _exploreConfig).test(
      '結果には読み取り可能なエントリのみが含まれる（hasError == false）',
      (documents) {
        final result = filterErrorResilient(documents);

        // フィルタ結果のすべてのエントリが hasError == false であること
        for (final entry in result) {
          expect(
            entry.hasError,
            isFalse,
            reason: 'エラーフラグ付きエントリが結果に含まれている: $entry',
          );
        }
      },
    );

    Glados(any.imageDocumentListWithErrors, _exploreConfig).test(
      '結果にはエラーのあるエントリ（hasError == true）は含まれない',
      (documents) {
        final result = filterErrorResilient(documents);

        // フィルタ結果にエラーエントリが含まれないことを確認
        final errorEntries = result.where((doc) => doc.hasError);
        expect(errorEntries, isEmpty, reason: 'エラーエントリが結果に含まれている');
      },
    );

    Glados(any.imageDocumentListWithErrors, _exploreConfig).test(
      '結果の件数は元リスト内の読み取り可能エントリ数と一致する',
      (documents) {
        final result = filterErrorResilient(documents);

        // 元リスト内の読み取り可能エントリ数をカウント
        final expectedCount = documents.where((doc) => !doc.hasError).length;

        expect(
          result.length,
          equals(expectedCount),
          reason: '結果の件数 (${result.length}) が期待値 ($expectedCount) と一致しない',
        );
      },
    );

    Glados(any.imageDocumentListWithErrors, _exploreConfig).test(
      '結果は元リストの読み取り可能エントリと完全に一致する（順序保持）',
      (documents) {
        final result = filterErrorResilient(documents);

        // 元リストから読み取り可能エントリのみを抽出（順序保持）
        final expected = documents.where((doc) => !doc.hasError).toList();

        expect(result, equals(expected));
      },
    );

    Glados(any.imageDocumentListWithErrors, _exploreConfig).test(
      'エラーエントリが存在しても処理は中断されない（例外がスローされない）',
      (documents) {
        // filterErrorResilient が例外をスローせずに完了することを検証
        // （エラーエントリをスキップして継続する）
        final result = filterErrorResilient(documents);

        // 結果が null でないこと（正常に完了した証拠）
        expect(result, isNotNull);
        // 結果がリストであること
        expect(result, isA<List<ImageDocumentWithError>>());
      },
    );

    Glados(any.list(any.nonEmptyLetters), _exploreConfig).test(
      'すべて読み取り可能なリストはフィルタ後も全件残る',
      (names) {
        final documents = names
            .map(
              (name) => ImageDocumentWithError(
                documentId: 'primary:DCIM/$name',
                name: '$name.jpg',
                hasError: false,
              ),
            )
            .toList();

        final result = filterErrorResilient(documents);

        expect(result.length, equals(documents.length));
        expect(result, equals(documents));
      },
    );

    Glados(any.list(any.nonEmptyLetters), _exploreConfig).test(
      'すべてエラーのリストはフィルタ後に空になる',
      (names) {
        final documents = names
            .map(
              (name) => ImageDocumentWithError(
                documentId: 'primary:DCIM/$name',
                name: '$name.jpg',
                hasError: true,
              ),
            )
            .toList();

        final result = filterErrorResilient(documents);

        expect(result, isEmpty);
      },
    );
  });
}
