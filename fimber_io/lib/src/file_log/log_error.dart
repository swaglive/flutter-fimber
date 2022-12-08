import 'package:fimber/fimber.dart';

class LogError {
  final String message;
  final String tag;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  factory LogError({
    required String message,
    required dynamic error,
    required String tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) =>
      LogError._(
        message: message,
        error: error,
        tag: tag,
        stackTrace: stackTrace,
        context: context != null ? jsonifyContext(context) : null,
      );

  LogError._({
    required this.message,
    required this.error,
    required this.tag,
    this.stackTrace,
    this.context,
  });
}
