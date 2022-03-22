import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fimber/fimber.dart';
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
          try {
            // check if file's directory exists
            final parentDir = file.parent;
            if (!parentDir.existsSync()) {
              parentDir.createSync(recursive: true);
            }
            logSink = file.openWrite(mode: FileMode.writeOnlyAppend);
            for (var newLine in buffer) {
              logSink.writeln(newLine);
            }
            await logSink.flush();
          } finally {
            await logSink?.close();
          }
          try {
            final fileSize = file.lengthSync();
            onBufferFlushed(file.path, fileSize);
          } on FileSystemException catch (_) {}
        }
      });

  @override
  void printLine(String line, {String? level}) {
    var colorizeWrapper = (level != null) ? colorizeMap[level] : null;
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
  }
}
