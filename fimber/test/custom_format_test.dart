// ignore_for_file: leading_newlines_in_multiline_strings

import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  group("Custom format", () {
    test('Format based logger', () {
      Fimber.clearAll();
      final defaultFormat = AssertFormattedTree();

      final elapsedMsg = AssertFormattedTree.elapsed(
        logFormat: '''${CustomFormatTree.timeElapsedToken}
${CustomFormatTree.messageToken}''',
      );
      Fimber.plantTree(defaultFormat);
      Fimber.plantTree(elapsedMsg);

      Fimber.i("Test message A");
      Fimber.i("Test Message B", ex: Exception("Test exception"));

      assert(
        defaultFormat.logLineHistory[0]
            .contains("I [main.<ac>.<ac>] Test message A"),
      );
      assert(
        defaultFormat.logLineHistory[1]
            .contains("I [main.<ac>.<ac>] Test Message B"),
      );
      expect(
        defaultFormat.logLineHistory[0]
            .substring("2019-01-18T09:15:08.980493".length + 1),
        "I [main.<ac>.<ac>] Test message A  ",
      );

      assert(elapsedMsg.logLineHistory[0].contains("Test message A"));
      expect(
        "Test message A",
        elapsedMsg.logLineHistory[0].substring("0:00:00.008303".length + 1),
      );
    });

    test('Single Label format', () {
      Fimber.clearAll();
      final format = AssertFormattedTree(
        logFormat:
            '${CustomFormatTree.labelsToken} ${CustomFormatTree.messageToken}',
      );
      Fimber.plantTree(format);

      Fimber.i('Test', labels: {'Label-A'});

      expect(format.logLineHistory[0], '<Label-A> Test');
    });

    test('Multiple Labels format', () {
      Fimber.clearAll();
      final format = AssertFormattedTree(
        logFormat:
            '${CustomFormatTree.labelsToken} ${CustomFormatTree.messageToken}',
      );

      Fimber.plantTree(format);

      Fimber.i('Test 1', labels: {'A-Label', 'B-Label'});
      Fimber.i('Test 2', labels: {'B-Label', 'A-Label'});

      expect(format.logLineHistory[0], '<A-Label><B-Label> Test 1');
      expect(format.logLineHistory[1], '<A-Label><B-Label> Test 2');
    });
  });
}

class AssertFormattedTree extends CustomFormatTree {
  AssertFormattedTree({
    String logFormat = CustomFormatTree.defaultFormat,
  }) : super(logFormat: logFormat);

  factory AssertFormattedTree.elapsed({
    String logFormat = CustomFormatTree.defaultFormat,
  }) {
    return AssertFormattedTree(logFormat: logFormat);
  }

  List<String> logLineHistory = [];

  @override
  void printLine(String line, {String? level}) {
    logLineHistory.add(line);
    super.printLine(line, level: level);
  }
}
