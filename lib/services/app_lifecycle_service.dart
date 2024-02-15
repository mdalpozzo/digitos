import 'package:flutter/widgets.dart';

class AppLifecycleService with WidgetsBindingObserver {
  bool _hasStarted = false;

  final List<VoidCallback> _onStartCallbacks = [];
  final List<VoidCallback> _onResumedCallbacks = [];
  final List<VoidCallback> _onPausedCallbacks = [];

  AppLifecycleService() {
    WidgetsBinding.instance.addObserver(this);
    _triggerAppStart();
  }

  void _triggerAppStart() {
    if (!_hasStarted) {
      for (var callback in _onStartCallbacks) {
        callback();
      }
      _hasStarted = true; // Ensure this only runs once
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
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
    WidgetsBinding.instance.removeObserver(this);
  }
}
