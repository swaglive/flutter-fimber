import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:fimber_io/src/file_log/log_error.dart';
import 'package:synchronized/extension.dart';

abstract class FileSizeListener {
  void onBufferFlushed(String fileName, int fileSize);
}

/// File based logging output tree.
/// This tree if planted will post short formatted (elapsed time and message)
/// output into file specified in constructor.
/// Note: Mostly for testing right now
abstract class FileTree extends CustomFormatTree
    with CloseableTree
    implements FileSizeListener {
  /// Interval for buffer write to file. In milliseconds
  static const defaultBufferFlushInterval = 500;

  /// Size limit (bytes) in temporary buffer.
  static const defaultBufferSizeLimit = 1024;

  /// Output current log file name.
  String outputFileName;

  /// Max size of buffer.
  int maxBufferSize;

  int _bufferSize = 0;
  List<String> _buffers = [];
  StreamSubscription<List<String>>? _flushTimer;
  final _errorStreamController = StreamController<LogError>.broadcast();
  Stream<LogError> get onError => _errorStreamController.stream;
  final String _tag = 'FileTree';

  /// Creates Instance of FimberFileTree
  /// with optional [logFormat] from [CustomFormatTree] predicates.
  /// Takes optional [maxBufferSize] (default 1kB) and
  /// optional [bufferWriteInterval] in milliseconds.
  FileTree(
    this.outputFileName, {
    List<String> logLevels = CustomFormatTree.defaultLevels,
    String logFormat =
        '${CustomFormatTree.timeStampToken}\t${CustomFormatTree.messageToken}',
    this.maxBufferSize = FileTree.defaultBufferSizeLimit,
    int bufferWriteInterval = FileTree.defaultBufferFlushInterval,
  }) : super(logLevels: logLevels, logFormat: logFormat) {
    _flushTimer =
        Stream.periodic(Duration(milliseconds: bufferWriteInterval), (i) {
      final dumpBuffer = _buffers;
      _buffers = [];
      _bufferSize = 0;
      return dumpBuffer;
    }).listen((newLines) async {
      await _flushBuffer(newLines);
    });
  }

  void addError(LogError error) {
    if (_errorStreamController.isClosed) {
      return;
    }
    _errorStreamController.add(error);
  }

  void _checkSizeForFlush() {
    if (_bufferSize > maxBufferSize) {
      final dumpBuffer = _buffers;
      _buffers = [];
      _bufferSize = 0;
      Future.microtask(() {
        _flushBuffer(dumpBuffer);
      });
    }
  }

  Future<void> _flushBuffer(List<String> buffer) => synchronized(() async {
        if (buffer.isNotEmpty) {
          IOSink? logSink;
          final file = File(outputFileName);
          final context = {'step': 'init'};
          try {
            // check if file's directory exists
            final parentDir = file.parent;
            if (!parentDir.existsSync()) {
              context['step'] = 'create file';
              parentDir.createSync(recursive: true);
            }
            context['step'] = 'open file';
            logSink = file.openWrite(mode: FileMode.writeOnlyAppend);
            context['step'] = 'write lines';
            for (final String newLine in buffer) {
              logSink.writeln(newLine);
            }
            context['step'] = 'flush file';
            await logSink.flush();
          } catch (e, s) {
            addError(
              LogError(
                message: 'Cannot flush buffer',
                tag: _tag,
                error: e,
                stackTrace: s,
                context: context,
              ),
            );
          } finally {
            await logSink?.close();
          }
          try {
            context['step'] = 'read length';
            final fileSize = file.lengthSync();
            context['step'] = 'notify listeners';
            onBufferFlushed(file.path, fileSize);
          } on FileSystemException catch (e, s) {
            addError(
              LogError(
                message: 'Cannot report flush',
                tag: _tag,
                error: e,
                stackTrace: s,
                context: {...context, 'reason': 'file system error'},
              ),
            );
          } catch (e, s) {
            addError(
              LogError(
                message: 'Cannot report flush',
                tag: _tag,
                error: e,
                stackTrace: s,
                context: {...context, 'reason': 'unknown'},
              ),
            );            
          }
        }
      });

  @override
  void printLine(String line, {String? level}) {
    final ColorizeStyle? colorizeWrapper =
        (level != null) ? colorizeMap[level] : null;
    if (colorizeWrapper != null) {
      _buffers.add(colorizeWrapper.wrap(line));
    } else {
      _buffers.add(line);
    }
    _bufferSize += line.length;
    _checkSizeForFlush();
  }

  @override
  void close() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _errorStreamController.close();
  }
}
