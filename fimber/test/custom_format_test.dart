import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  group("Custom format", () {
    test('Format based logger', () {
      Fimber.clearAll();
      var defaultFormat = AssertFormattedTree();

      var elapsedMsg = AssertFormattedTree.elapsed(
          logFormat: '''${CustomFormatTree.timeElapsedToken}
${CustomFormatTree.messageToken}''');
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
}

class AssertFormattedTree extends CustomFormatTree {
  AssertFormattedTree(
      {String logFormat = CustomFormatTree.defaultFormat,
      int printTimeType = CustomFormatTree.timeClockFlag})
      : super(logFormat: logFormat);

  factory AssertFormattedTree.elapsed(
      {String logFormat = CustomFormatTree.defaultFormat}) {
    return AssertFormattedTree(logFormat: logFormat);
  }

  List<String> logLineHistory = [];

  @override
  void printLine(String line, {String? level}) {
    logLineHistory.add(line);
    super.printLine(line, level: level);
  }
}
