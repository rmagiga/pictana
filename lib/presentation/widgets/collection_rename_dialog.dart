/// コレクション名変更ダイアログ
///
/// 現在の名前をプリフィルした名前入力フィールド + バリデーションエラー表示 +
/// 50文字制限を備えたダイアログ。
/// [RenameCollectionUseCase] を呼び出し、リネームに成功した場合は
/// 更新後の [Collection] を返して閉じる。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/collection_exceptions.dart';
import '../../domain/entities/collection.dart';
import '../../domain/value_objects/collection_name.dart';
import '../providers/collection_list_provider.dart';

/// コレクション名変更ダイアログを表示する
///
/// リネームに成功した場合は更新後の [Collection] を返し、キャンセル時は null を返す。
Future<Collection?> showCollectionRenameDialog(
  BuildContext context,
  int collectionId,
  String currentName,
) {
  return showDialog<Collection>(
    context: context,
    builder: (context) => CollectionRenameDialog(
      collectionId: collectionId,
      currentName: currentName,
    ),
  );
}

/// コレクション名変更ダイアログ
///
/// - 現在の名前をプリフィルした入力フィールド（最大50文字）
/// - バリデーションエラーのインライン表示
/// - RenameCollectionUseCase による更新処理
/// - 永続化失敗時はエラー表示 + 入力保持
class CollectionRenameDialog extends ConsumerStatefulWidget {
  const CollectionRenameDialog({
    required this.collectionId,
    required this.currentName,
    super.key,
  });

  /// 変更対象のコレクション ID
  final int collectionId;

  /// 現在のコレクション名（プリフィル用）
  final String currentName;

  @override
  ConsumerState<CollectionRenameDialog> createState() =>
      _CollectionRenameDialogState();
}

class _CollectionRenameDialogState
    extends ConsumerState<CollectionRenameDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 現在の名前をプリフィル
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 入力値のバリデーションエラーメッセージを返す（エラーなしは null）
  String? _getValidationError(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'コレクション名を入力してください';
    }
    if (trimmed.length > CollectionName.maxLength) {
      return 'コレクション名は${CollectionName.maxLength}文字以内で入力してください';
    }
    if (trimmed.contains('\n') || trimmed.contains('\r')) {
      return 'コレクション名に改行を含めることはできません';
    }
    return null;
  }

  /// CollectionNameException からユーザー向けエラーメッセージを生成する
  String _getExceptionMessage(CollectionNameException exception) {
    return switch (exception) {
      CollectionNameEmptyException() => 'コレクション名を入力してください',
      CollectionNameTooLongException() =>
        'コレクション名は${CollectionName.maxLength}文字以内で入力してください',
      CollectionNameContainsNewlineException() => 'コレクション名に改行を含めることはできません',
      CollectionNameDuplicateException(:final existingName) =>
        '「$existingName」は既に使用されています',
    };
  }

  /// 変更ボタン押下時の処理
  Future<void> _onSubmit() async {
    final input = _controller.text;

    // ローカルバリデーション
    final validationError = _getValidationError(input);
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      final useCase = ref.read(renameCollectionUseCaseProvider);
      final collection = await useCase.execute(widget.collectionId, input);

      // リネーム成功: ダイアログを閉じて更新後の Collection を返す
      if (mounted) {
        Navigator.of(context).pop(collection);
      }
    } on CollectionNameException catch (e) {
      // バリデーション/重複エラー: インラインエラー表示 + 入力保持
      if (mounted) {
        setState(() {
          _errorText = _getExceptionMessage(e);
          _isSubmitting = false;
        });
      }
    } catch (_) {
      // 永続化失敗等の予期しないエラー: エラー表示 + 入力保持
      if (mounted) {
        setState(() {
          _errorText = 'コレクション名の変更に失敗しました。もう一度お試しください。';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('コレクション名を変更'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: CollectionName.maxLength,
        decoration: InputDecoration(
          labelText: 'コレクション名',
          hintText: 'コレクション名を入力',
          errorText: _errorText,
          errorMaxLines: 2,
        ),
        onChanged: (_) {
          // 入力変更時にエラーをクリア
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
        onSubmitted: (_) => _onSubmit(),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _onSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('変更'),
        ),
      ],
    );
  }
}
