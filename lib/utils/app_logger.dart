import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  static void d(String msg) => _logger.d(msg);
  static void i(String msg) => _logger.i(msg);
  static void w(String msg) => _logger.w(msg);
  static void e(String msg, {Object? error, StackTrace? stack, required StackTrace stackTrace}) {
    _logger.e(msg, error: error, stackTrace: stack);
  }
}
