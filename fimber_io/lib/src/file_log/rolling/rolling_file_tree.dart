import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:fimber_io/src/file_log/log_error.dart';
import 'package:intl/intl.dart';

import '../file_tree.dart';

abstract class RollingFileTree extends FileTree {
  static final DateFormat dateFormat = DateFormat('yyyy_MM_dd_HH_mm_ss');

  final String directory;
  final String filenamePrefix;
  final String filenamePostfix;
  final int maxAmountOfFile;

  List<int> fileIdList = [];
  int currentFileId = 0;
  final String _tag = 'RollingFileTree';

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
    final Directory rootDir = Directory(directory);
    try {
      if (!rootDir.existsSync()) {
        /// no files created yet.
        currentFileId = 0;
        onInitDone(fileIdList);
        // rollToNextFile();
        return;
      }
    } catch (e, s) {
      addError(
        LogError(
          message: 'Cannot check log file existence',
          error: e,
          stackTrace: s,
          tag: _tag,
        ),
      );
      return;
    }
    try {
      fileIdList = rootDir
          .listSync()
          .map((fe) {
            final int index = getLogIndex(fe.path);
            if (index < 0) {
              fe.delete().catchError((e, s) {
                addError(
                  LogError(
                    message: 'Cannot delete file',
                    error: e,
                    stackTrace: s,
                    tag: _tag,
                    context: {'path': fe.path},
                  ),
                );
              });
            }
            return index;
          })
          .where((i) => i >= 0)
          .toList();
      fileIdList.sort();
      // ignore: avoid_print
      print('Fimber-IO: log list indexes: $fileIdList');
      onInitDone(fileIdList);
    } catch (e, s) {
      addError(
        LogError(
          message: 'Cannot init fileIdList',
          error: e,
          stackTrace: s,
          tag: _tag,
        ),
      );      
    }
  }

  String currentFile() => logFileFromId(currentFileId);

  String logFileFromId(int id) {
    return logFile(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(id)));
  }

  String logFile(String fileName) =>
      '$directory/$filenamePrefix$fileName$filenamePostfix';

  RegExp get _fileRegExp =>
      RegExp(r'(\d{4}_\d\d_\d\d_\d\d_\d\d_\d\d)', caseSensitive: false);

  int getCurrentIndex() =>
      (DateTime.now().millisecondsSinceEpoch / 1000).floor() * 1000;

  /// Gets log index from a file path.
  int getLogIndex(String filePath) {
    if (isLogFile(filePath)) {
      return _fileRegExp.allMatches(filePath).map((match) {
        if (match.groupCount > 0) {
          final parseGroup = match.group(0);
          if (parseGroup != null) {
            final conext = {'filePath': filePath, 'parseGroup': parseGroup};
            try {
              return dateFormat.parse(parseGroup).millisecondsSinceEpoch;
            } on FormatException catch (e, s) {
              addError(
                LogError(
                  message: 'Cannot parse ',
                  error: e,
                  stackTrace: s,
                  tag: _tag,
                  context: {...conext, 'reason': 'format error'},
                ),
              );
              return -1;
            } catch (e, s) {
              addError(
                LogError(
                  message: 'Cannot parse ',
                  error: e,
                  stackTrace: s,
                  tag: _tag,
                  context: {...conext, 'reason': 'unknown'},
                ),
              );
              rethrow;
            }
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

  @override
  void printLine(String line, {String? level}) {
    super.printLine('$line\n', level: level);
  }
}
