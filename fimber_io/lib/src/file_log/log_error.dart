import 'package:fimber/fimber.dart';

class LogError {
  final String message;
  final String tag;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  LogError({
    required this.message,
    required this.error,
    required this.tag,
    this.stackTrace,
    this.context,
  });
}
