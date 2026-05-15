import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const String _appTag = '[HealthNorth]';

  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  static void error(String message, {String? tag, Object? exception, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag);
    if (exception != null) {
      _log(LogLevel.error, 'Exception: $exception', tag: tag);
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('$_appTag [STACK] $stackTrace');
    }
  }

  static void network({
    required String method,
    required String url,
    int? statusCode,
    String? body,
  }) {
    if (kDebugMode) {
      final status = statusCode != null ? ' -> $statusCode' : '';
      debugPrint('$_appTag [NET] $method $url$status');
      if (body != null && body.isNotEmpty) {
        debugPrint('$_appTag [NET] Body: $body');
      }
    }
  }

  static void _log(LogLevel level, String message, {String? tag}) {
    if (!kDebugMode) return;
    final label = _levelLabel(level);
    final tagPart = tag != null ? '[$tag]' : '';
    debugPrint('$_appTag $label$tagPart $message');
  }

  static String _levelLabel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }
}
