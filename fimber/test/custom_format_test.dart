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

      expect(
        defaultFormat.logLineHistory[0]
            .contains("I [main.<ac>.<ac>] Test message A"),
        true,
      );
      expect(
        defaultFormat.logLineHistory[1]
            .contains("I [main.<ac>.<ac>] Test Message B"),
        true,
      );
      expect(
        defaultFormat.logLineHistory[0]
            .substring("2019-01-18T09:15:08.980493".length + 1)
            .startsWith("I [main.<ac>.<ac>] Test message A"),
        true,
      );

      expect(elapsedMsg.logLineHistory[0].contains("Test message A"), true);
      expect("Test message A",
          elapsedMsg.logLineHistory[0].substring("0:00:00.008303".length + 1));
    });

    test('Single Label format', () {
      Fimber.clearAll();
      var format = AssertFormattedTree(
          logFormat:
              '${CustomFormatTree.labelsToken} ${CustomFormatTree.messageToken}');
      Fimber.plantTree(format);

      Fimber.i('Test', labels: {'Label-A'});

      expect(format.logLineHistory[0], '<Label-A> Test');
    });

    test('Multiple Labels format', () {
      Fimber.clearAll();
      var format = AssertFormattedTree(
          logFormat:
              '${CustomFormatTree.labelsToken} ${CustomFormatTree.messageToken}');

      Fimber.plantTree(format);

      Fimber.i('Test 1', labels: {'A-Label', 'B-Label'});
      Fimber.i('Test 2', labels: {'B-Label', 'A-Label'});

      expect(format.logLineHistory[0], '<A-Label><B-Label> Test 1');
      expect(format.logLineHistory[1], '<A-Label><B-Label> Test 2');
    });
  });

  group('Debug fromat', () {
    test('Tag format', () {
      Fimber.clearAll();
      final debugTree = AssertDebugTree();
      Fimber.plantTree(debugTree);

      Fimber.i('Message 1', tag: 'tag-1');
      Fimber.i('Message 2', tag: 'tag-2');

      expect(debugTree.logLineHistory[0].contains('[tag-1]'), true);
      expect(debugTree.logLineHistory[1].contains('[tag-2]'), true);
    });

    test('Single label fromat', () {
      Fimber.clearAll();
      final debugTree = AssertDebugTree();
      Fimber.plantTree(debugTree);

      Fimber.i('Message 1', labels: {'label-1'});
      Fimber.i('Message 2', labels: {'label-2'});

      expect(debugTree.logLineHistory[0].contains('[label-1]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2]'), true);
    });

    test('Multiple labels fromat', () {
      Fimber.clearAll();
      final debugTree = AssertDebugTree();
      Fimber.plantTree(debugTree);

      Fimber.i('Message 1', labels: {'label-1a', 'label-1b'});
      Fimber.i('Message 2', labels: {'label-2a', 'label-2b', 'label-2c'});

      expect(debugTree.logLineHistory[0].contains('[label-1a]'), true);
      expect(debugTree.logLineHistory[0].contains('[label-1b]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2a]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2b]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2c]'), true);
    });

    test('label and tag fromat', () {
      Fimber.clearAll();
      final debugTree = AssertDebugTree();
      Fimber.plantTree(debugTree);

      Fimber.i('Message 1', tag: 'tag-1', labels: {'label-1a', 'label-1b'});
      Fimber.i(
        'Message 2',
        tag: 'tag-2',
        labels: {'label-2a', 'label-2b', 'label-2c'},
      );

      expect(debugTree.logLineHistory[0].contains('[tag-1]'), true);
      expect(debugTree.logLineHistory[0].contains('[label-1a]'), true);
      expect(debugTree.logLineHistory[0].contains('[label-1b]'), true);
      expect(debugTree.logLineHistory[1].contains('[tag-2]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2a]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2b]'), true);
      expect(debugTree.logLineHistory[1].contains('[label-2c]'), true);
    });

    test('Still print without labels nor tag', () {
      Fimber.clearAll();
      final debugTree = AssertDebugTree();
      Fimber.plantTree(debugTree);

      Fimber.i('Message 1');
      Fimber.i('Message 2');

      expect(debugTree.logLineHistory[0].contains('Message 1'), true);
      expect(debugTree.logLineHistory[1].contains('Message 2'), true);
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

class AssertDebugTree extends DebugTree {
  List<String> logLineHistory = [];

  @override
  void printLog(String logLine, {String? level}) {
    logLineHistory.add(logLine);
    super.printLog(logLine, level: level);
  }
}
