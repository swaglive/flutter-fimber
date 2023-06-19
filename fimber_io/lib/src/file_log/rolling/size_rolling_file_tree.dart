import 'dart:io';

import 'package:fimber/fimber.dart';

import '../file_tree.dart';
import 'rolling_file_tree.dart';

class SizeRollingFileTree extends RollingFileTree {
  final DataSize maxDataSize;

  SizeRollingFileTree({
    required this.maxDataSize,
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
    if (_isFileOverSize(logFileFromId(fileIdList.last))) {
      rollToNextFile();
    } else {
      currentFileId = fileIdList.last;
      outputFileName = logFileFromId(currentFileId);
    }
  }

  @override
  void onBufferFlushed(String fileName, int fileSize) {
    if (fileName == outputFileName && fileSize > maxDataSize.realSize) {
      rollToNextFile();
    }
  }

  @override
  void rollToNextFile() {
    currentFileId = getCurrentIndex();
    outputFileName = currentFile();
    if (!fileIdList.contains(currentFileId)) {
      fileIdList.add(currentFileId);
    }

    /// remove old log file.
    final int deleteCount = fileIdList.length - maxAmountOfFile;
    final indexes = List.from(fileIdList);
    if (deleteCount > 0) {
      for (int i = 0; i < deleteCount; i++) {
        final file = File(logFileFromId(indexes[i]));
        if (file.existsSync()) {
          file.deleteSync();
        }
        fileIdList.removeAt(i);
      }
    }
  }

  bool _isFileOverSize(String path) {
    final File file = File(path);
    if (file.existsSync()) {
      return file.lengthSync() > maxDataSize.realSize;
    } else {
      return false;
    }
  }
}
