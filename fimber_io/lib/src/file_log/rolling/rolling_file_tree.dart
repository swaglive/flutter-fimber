import 'dart:io';

import 'package:fimber/fimber.dart';

import '../file_tree.dart';

abstract class RollingFileTree extends FileTree {
  final String directory;
  final String filenamePrefix;
  final String filenamePostfix;
  final int maxAmountOfFile;

  List<int> fileIdList = [];
  int currentFileId = 0;

  RollingFileTree({
    String logFormat = CustomFormatTree.defaultFormat,
    List<String> logLevels = CustomFormatTree.defaultLevels,
    this.directory = '',
    this.filenamePrefix = 'log_',
    this.filenamePostfix = '.txt',
    this.maxAmountOfFile = 10,
    int maxBufferSize = FileTree.defaultBufferSizeLimit,
    int bufferWriteInterval = FileTree.defaultBufferFlushInterval,
  }) : super(
          '',
          logFormat: logFormat,
          logLevels: logLevels,
          maxBufferSize: maxBufferSize,
          bufferWriteInterval: bufferWriteInterval,
        ) {
    _detectFileIndex();
  }

  void onInitDone(List<int> fileIdList);

  void rollToNextFile();

  void _detectFileIndex() {
    var rootDir = Directory(directory);
    if (!rootDir.existsSync()) {
      /// no files created yet.
      currentFileId = 0;
      onInitDone(fileIdList);
      // rollToNextFile();
      return;
    }
    fileIdList = rootDir
        .listSync()
        .map((fe) => getLogIndex(fe.path))
        .where((i) => i >= 0)
        .toList();
    fileIdList.sort();
    print('Fimber-IO: log list indexes: $fileIdList');
    onInitDone(fileIdList);
  }

  String currentFile() {
    final fileName =
        DateTime.fromMillisecondsSinceEpoch(currentFileId).toIso8601String();
    return logFile(fileName);
  }

  String logFileFromId(int id) {
    return logFile(DateTime.fromMillisecondsSinceEpoch(id).toIso8601String());
  }

  String logFile(String fileName) =>
      '$directory/$filenamePrefix$fileName$filenamePostfix';

  RegExp get _fileRegExp =>
      RegExp('${r'\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?'}',
          caseSensitive: false);

  /// Gets log index from a file path.
  int getLogIndex(String filePath) {
    if (isLogFile(filePath)) {
      return _fileRegExp.allMatches(filePath).map((match) {
        if (match.groupCount > 0) {
          final parseGroup = match.group(0);
          if (parseGroup != null) {
            return DateTime.tryParse(parseGroup)?.millisecondsSinceEpoch ?? -1;
          }
        }
        return -1;
      }).firstWhere((i) => i != -1, orElse: () => -1);
    } else {
      return -1;
    }
  }

  bool isLogFile(String filePath) {
    return _fileRegExp.allMatches(filePath).map((match) {
      if (match.groupCount > 0) {
        return true;
      } else {
        return false;
      }
    }).lastWhere((_) => true, orElse: () => false);
  }
}
