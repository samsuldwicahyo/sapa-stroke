import 'dart:async';

import 'package:flutter/foundation.dart';

typedef ScanAction = Future<String?> Function();

class ScanTarget {
  const ScanTarget({
    required this.id,
    required this.onActivate,
  });

  final String id;
  final ScanAction onActivate;
}

class ScanningService extends ChangeNotifier {
  List<ScanTarget> _targets = const <ScanTarget>[];
  Duration _interval = const Duration(seconds: 3);
  bool _enabled = false;
  int _currentIndex = 0;
  Timer? _timer;
  Future<void> Function()? _onHighlightMoved;

  bool get enabled => _enabled;

  String? get currentItemId {
    if (!_enabled || _targets.isEmpty) {
      return null;
    }

    return _targets[_currentIndex].id;
  }

  void registerTargets({
    required List<ScanTarget> targets,
    required bool enabled,
    required Duration interval,
    Future<void> Function()? onHighlightMoved,
  }) {
    final List<String> oldIds =
        _targets.map((ScanTarget target) => target.id).toList(growable: false);
    final List<String> newIds =
        targets.map((ScanTarget target) => target.id).toList(growable: false);
    final bool changed =
        !listEquals(oldIds, newIds) || _interval != interval || _enabled != enabled;

    _targets = targets;
    _enabled = enabled;
    _interval = interval;
    _onHighlightMoved = onHighlightMoved;

    if (!_enabled || _targets.isEmpty) {
      clearTargets();
      return;
    }

    if (changed) {
      _currentIndex = 0;
      _restartTimer();
      notifyListeners();
    }
  }

  Future<String?> activateCurrent() async {
    if (!_enabled || _targets.isEmpty) {
      return null;
    }

    final ScanTarget target = _targets[_currentIndex];
    final String? message = await target.onActivate();
    resetToFirst();
    return message;
  }

  void resetToFirst() {
    if (_targets.isEmpty) {
      return;
    }

    _currentIndex = 0;
    notifyListeners();
  }

  void clearTargets() {
    _timer?.cancel();
    _timer = null;
    _targets = const <ScanTarget>[];
    _currentIndex = 0;
    notifyListeners();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) async {
      if (_targets.isEmpty) {
        return;
      }

      _currentIndex = (_currentIndex + 1) % _targets.length;
      notifyListeners();
      await _onHighlightMoved?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
