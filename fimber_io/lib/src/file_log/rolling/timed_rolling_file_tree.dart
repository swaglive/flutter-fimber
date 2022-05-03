import 'dart:io';

import 'package:fimber/fimber.dart';

import '../file_tree.dart';
import 'rolling_file_tree.dart';

class TimedRollingFileTree extends RollingFileTree {
  final Duration duration;

  TimedRollingFileTree({
    required this.duration,
    String logFormat = CustomFormatTree.defaultFormat,
    List<String> logLevels = CustomFormatTree.defaultLevels,
    String directory = '',
    String filenamePrefix = 'log_',
    String filenamePostfix = '.txt',
    int maxAmountOfFile = 10,
    int maxBufferSize = FileTree.defaultBufferSizeLimit,
    int bufferWriteInterval = FileTree.defaultBufferFlushInterval,
  }) : super(
          logFormat: logFormat,
          logLevels: logLevels,
          directory: directory,
          filenamePrefix: filenamePrefix,
          filenamePostfix: filenamePostfix,
          maxAmountOfFile: maxAmountOfFile,
          maxBufferSize: maxBufferSize,
          bufferWriteInterval: bufferWriteInterval,
        );

  @override
  void onInitDone(List<int> fileIdList) {
    if (fileIdList.isEmpty) {
      rollToNextFile();
      return;
    }
    final epoch = fileIdList.last;
    if (Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - epoch) >
        duration) {
      rollToNextFile();
      return;
    }
    currentFileId = fileIdList.last;
    outputFileName = logFileFromId(currentFileId);
  }

  @override
  void onBufferFlushed(String fileName, int fileSize) {}

  @override
  void printLine(String line, {String? level}) {
    final epoch = currentFileId;
    if (Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - epoch) >
        duration) {
      rollToNextFile();
    }
    super.printLine(line, level: level);
  }

  @override
  void rollToNextFile() {
    currentFileId = DateTime.now().millisecondsSinceEpoch;
    outputFileName = currentFile();
    final outputFile = File(outputFileName);
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    fileIdList.add(currentFileId);

    /// remove old log file.
    var deleteCount = fileIdList.length - maxAmountOfFile;
    final indexes = List.from(fileIdList);
    if (deleteCount > 0) {
      for (var i = 0; i < deleteCount; i++) {
        final file = File(logFile(indexes[i]));
        if (file.existsSync()) {
          file.deleteSync();
        }
        fileIdList.removeAt(i);
      }
    }
  }
}
