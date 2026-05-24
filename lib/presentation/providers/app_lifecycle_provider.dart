import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_provider.g.dart';

/// アプリケーションのライフサイクル状態を監視するProvider
@riverpod
class AppLifecycle extends _$AppLifecycle {
  @override
  AppLifecycleState build() {
    final observer = _LifecycleObserver((state) {
      this.state = state;
    });
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(observer);
    });
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  _LifecycleObserver(this._onChanged);
  final void Function(AppLifecycleState) _onChanged;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _onChanged(state);
  }
}
