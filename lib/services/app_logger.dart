import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
import 'package:logging/logging.dart'; // For Logger

class AppLogger {
  final String context;
  static late final File _logFile;
  static bool _isInitialized = false;

  AppLogger(this.context);

  static Future<void> initialize() async {
    if (_isInitialized) return;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    _logFile = File('${appDocDir.path}/app_logs.txt');

    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) async {
      String formattedMessage =
          '${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}';
      await _writeLog(formattedMessage);
    });

    _isInitialized = true;

    Logger('AppLogger').info('Logger initialized successfully');
  }

  static Future<void> _writeLog(String logMessage) async {
    try {
      await _logFile.writeAsString("$logMessage\n",
          mode: FileMode.append, flush: true);
    } catch (error) {
      // Fallback to console logging if writing to file fails
      print(
          "Failed to write to log file: $error; Original message: $logMessage");
    }
  }

  void fine(Object message) => _log(Level.FINE, message);
  void info(Object message) => _log(Level.INFO, message);
  void warning(Object message) => _log(Level.WARNING, message);
  void severe(Object message, [Object? error, StackTrace? stackTrace]) =>
      _log(Level.SEVERE, message, error, stackTrace);

  void _log(
    Level level,
    Object message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final String resolvedMessage =
        message is Function ? message() : message.toString();
    Logger(context).log(level, resolvedMessage, error, stackTrace);
  }
}
