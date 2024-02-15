import 'package:digitos/services/app_logger.dart';
import 'package:flutter/widgets.dart';

class AppLifecycleService {
  bool _hasStarted = false;
  static final _log = AppLogger('AppLifecycleService');

  final List<VoidCallback> _onStartCallbacks = [];
  final List<VoidCallback> _onResumedCallbacks = [];
  final List<VoidCallback> _onPausedCallbacks = [];

  AppLifecycleService();

  void handleAppStart() {
    _log.info('handleAppStart');

    if (!_hasStarted) {
      for (var callback in _onStartCallbacks) {
        callback();
      }
      _hasStarted = true; // Ensure this only runs once
    }
  }

  void handleAppLifecycleChange(AppLifecycleState state) {
    _log.info('handleAppLifecycleChange: $state');
    if (state == AppLifecycleState.resumed) {
      for (var callback in _onResumedCallbacks) {
        callback();
      }
    } else if (state == AppLifecycleState.paused) {
      for (var callback in _onPausedCallbacks) {
        callback();
      }
    }
  }

  void addOnStartCallback(VoidCallback callback) {
    if (!_hasStarted) {
      _onStartCallbacks.add(callback);
    } else {
      // If the app has already started, immediately trigger the callback
      callback();
    }
  }

  void removeOnStartCallback(VoidCallback callback) {
    _onStartCallbacks.remove(callback);
  }

  void addOnResumedCallback(VoidCallback callback) {
    _onResumedCallbacks.add(callback);
  }

  void removeOnResumedCallback(VoidCallback callback) {
    _onResumedCallbacks.remove(callback);
  }

  void addOnPausedCallback(VoidCallback callback) {
    _onPausedCallbacks.add(callback);
  }

  void removeOnPausedCallback(VoidCallback callback) {
    _onPausedCallbacks.remove(callback);
  }

  void dispose() {
    _onStartCallbacks.clear();
    _onResumedCallbacks.clear();
    _onPausedCallbacks.clear();
  }
}
