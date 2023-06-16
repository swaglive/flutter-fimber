import 'package:fimber/fimber.dart';
import 'package:fimber/src/fimber_base.dart';
import 'package:test/test.dart';

void main() {
  group("STATIC", () {
    test('log DEBUG when filtered out', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      expect('', assertTree.lastLogLine);
    });

    test('log DEBUG when expected', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D"]);
      Fimber.plantTree(DebugTree());
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine != '');
    });

    test('log DEBUG with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log INFO message tag', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W"]);
      Fimber.plantTree(assertTree);
      Fimber.i("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("I:main"));
    });

    test('log DEBUG message tag', () {
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("D:main"));
    });

    test('log VERBOSE message tag', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.v("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("V:main"));
    });

    test('log ERROR message tag', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.e("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("E:main"));
    });

    test('log WARNING message tag', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.w("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("W:main"));
    });
  });

  group("TAGGED", () {
    test('log VERBOSE message with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      var logger = FimberLog("MYTAG");
      logger.v("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("V:MYTAG"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log DEBUG message with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      var logger = FimberLog("MYTAG");
      logger.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("D:MYTAG"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log INFO message with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      var logger = FimberLog("MYTAG");
      logger.i("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("I:MYTAG"));
    });

    test('log WARNING message with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      var logger = FimberLog("MYTAG");
      logger.w("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("W:MYTAG"));
    });

    test('log ERROR message with exception', () {
      Fimber.clearAll();
      var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      var logger = FimberLog("MYTAG");
      logger.e("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("E:MYTAG"));
    });
  });

  test('Test with block tag', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());
    var someMessage = "Test message from outside of block";
    var output = Fimber.withTag("TEST BLOCK", (log) {
      log.d("Started block");
      var i = 0;
      for (i = 0; i < 10; i++) {
        log.d("$someMessage, value: $i");
      }
      log.i("End of block");
      return i;
    });
    expect(10, output);
    expect(12, assertTree.allLines.length);
    for (var line in assertTree.allLines) {
      // test tag
      assert(line.contains("TEST BLOCK"));
    }
    ;
    //inside lines contain external value
    for (var line in assertTree.allLines.sublist(1, 11)) {
      assert(line.contains(someMessage));
      assert(line.contains("D:TEST BLOCK"));
    }
    ;
  });

  test('Test with block autotag', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());
    var someMessage = "Test message from outside of block";
    var output = Fimber.block((log) {
      log.d("Started block");
      var i = 0;
      for (i = 0; i < 10; i++) {
        log.d("$someMessage, value: $i");
      }
      log.i("End of block");
      return i;
    });
    expect(10, output);
    expect(12, assertTree.allLines.length); // 10 + start and end line
    for (var line in assertTree.allLines) {
      // test tag
      assert(line.contains("main"));
    }
    ;
    //inside lines contain external value
    for (var line in assertTree.allLines.sublist(1, 11)) {
      assert(line.contains(someMessage));
      assert(line.contains("D:main"));
    }
  });

  test('Unplant trees test', () {
    Fimber.clearAll();
    var assertTreeA = AssertTree(["I", "W", "D", "E", "V"]);
    var assertTreeB = AssertTree(["I", "W", "E"]);
    Fimber.plantTree(assertTreeA);
    Fimber.plantTree(assertTreeB);
    Fimber.plantTree(DebugTree(printTimeType: DebugTree.timeElapsedType));

    Fimber.e("Test Error");
    Fimber.w("Test Warning");
    Fimber.i("Test Info");
    Fimber.d("Test Debug");

    expect(4, assertTreeA.allLines.length);
    expect(3, assertTreeB.allLines.length);

    Fimber.unplantTree(assertTreeA);
    Fimber.i("Test Info");
    Fimber.d("Test Debug");
    Fimber.w("Test Warning");
    Fimber.e("Test Error");

    expect(4, assertTreeA.allLines.length);
    expect(6, assertTreeB.allLines.length);
  });

  test('Constructor Log Tag generation', () {
    Fimber.clearAll();

    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());

    Fimber.i("Start log test");
    TestClass();
    Fimber.i("End log test");
    expect(3, assertTree.allLines.length);
    assert(assertTree.allLines[1].contains("new TestClass"));
  });

  test('Factory method Log Tag generation', () {
    Fimber.clearAll();

    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());

    Fimber.i("Start log test");
    TestClass.factory1();
    Fimber.i("End log test");
    expect(4, assertTree.allLines.length);
    assert(assertTree.allLines[1].contains("new TestClass.factory1"));
    assert(assertTree.allLines[2].contains("new TestClass"));
  });

  test('Throw Error and other any class', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());
    Fimber.i("Test log statement");
    Fimber.i("Test throw ERROR", ex: ArgumentError.notNull("testValue"));
    Fimber.i("Test throw DATA", ex: TestClass());
    Fimber.w("End log statment");
    assert(assertTree.allLines[1]
        .contains("Invalid argument(s) (testValue): Must not be null"));
    assert(assertTree.allLines[3].contains("TestClass.instance"));
  });

  test('Test Stacktrace', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());
    Fimber.i("Test log statement");
    var testClass = TestClass();
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Fimber.w("Error caught 1", ex: e, stacktrace: s);
    }
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Fimber.w("Error caught 2", ex: e);
    }
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Fimber.w("Error caught 3", stacktrace: s);
    }
    // with stacktrace provided
    assert(assertTree.allLines[2].contains("Error caught"));
    assert(assertTree.allLines[2].contains("Test exception from TestClass"));
    assert(assertTree.allLines[2].contains("TestClass.throwSomeError"));
    // without stacktrace provided
    assert(assertTree.allLines[3].contains("Test exception from TestClass"));
    assert(!assertTree.allLines[3].contains("TestClass.throwSomeError"));
    // without exception

    assert(assertTree.allLines[4].contains("Error caught"));

    assert(!assertTree.allLines[4].contains("Test exception from TestClass"));
    assert(assertTree.allLines[4].contains("TestClass.throwSomeError"));
  });

  test('Test mute/unmute', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["V", "I", "D", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.i("Test INFO log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.unmute("I");
    Fimber.i("Test INFO unmute log.");

    expect(2, assertTree.allLines.length);
    assert(assertTree.allLines[0].contains("Test INFO log."));
    assert(assertTree.allLines[1].contains("Test INFO unmute log."));
  });

  test('Test Multiple mute and unmute', () {
    Fimber.clearAll();
    var assertTree = AssertTree(["V", "I", "D", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.i("Test INFO log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.unmute("I");
    Fimber.i("Test INFO unmute log.");

    expect(2, assertTree.allLines.length);
    assert(assertTree.allLines[0].contains("Test INFO log."));
    assert(assertTree.allLines[1].contains("Test INFO unmute log."));
  });

  group("Custom format tree", () {
    test("Test custom format with linenumber", () {
      final formatTree = AssertFormatTree(
          "${CustomFormatTree.tagToken}\t${CustomFormatTree.fileNameToken}\t- ${CustomFormatTree.filePathToken} : ${CustomFormatTree.lineNumberToken}");
      Fimber.plantTree(formatTree);
      Fimber.i("Test message");
      final testLine = formatTree.allLines.first;
      expect(
        testLine.startsWith('main.<ac>.<ac>\tfimber_test.dart\t- //Users'),
        true,
      );
      /**
       NOTE: 
       1. This line tests `Fimber.i("Test message");`, which is sensitive to the actual location of that line.
          When encounter failure, check the line number first.
       2. The path should be agnostic to project folder name and computer user name. 
          If the 1. check passes but still having error, check if the path of this file shoulb be updated.
       */
      expect(
        testLine.endsWith('/fimber/test/fimber_test.dart : 340'),
        true,
      );
      Fimber.unplantTree(formatTree);
    });
  });

  group("COLORIZE", () {
    test("Debug colors - visual test only", () {
      Fimber.clearAll();
      Fimber.plantTree(
          DebugTree(logLevels: ["V", "D", "I", "W", "E"], useColors: true));
      Fimber.v("verbose logging");
      Fimber.d("debug logging");
      Fimber.i("info logging");
      Fimber.w("warning logging");
      Fimber.e("error logging");
    });
  });

  group("Global context provider", () {
    test("GlobalContextProvider is called when logging", () {
      int called = 0;
      Fimber.globalContextProvider = () {
        called += 1;
        return null;
      };

      Fimber.v("verbose logging");
      Fimber.d("debug logging");
      Fimber.i("info logging");
      Fimber.w("warning logging");
      Fimber.e("error logging");

      expect(called, 5);
    });
  });

  group('Labeling', () {
    test('Single label', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      Fimber.d('Test 1', labels: {'Label-A'});

      expect(tree.logLines[0].labels, {'Label-A'});
    });

    test('Change labels', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      Fimber.d('Test 1', labels: {'Label-A'});
      Fimber.d('Test 2', labels: {'Label-B'});

      expect(tree.logLines[0].labels, {'Label-A'});
      expect(tree.logLines[1].labels, {'Label-B'});
    });

    test('Multiple labels', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      Fimber.d('Test 1', labels: {'Label-A', 'Label-B'});

      expect(tree.logLines[0].labels, {'Label-A', 'Label-B'});
    });

    test('Tag should be included as a label', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      Fimber.d('Test 1', tag: 'Tag-A');

      expect(tree.logLines[0].labels, {'Tag-A'});
    });

    test('Labels merges tag', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      Fimber.d('Test 1', tag: 'Tag-A', labels: {'Label-A', 'Label-B'});
      Fimber.d('Test 2', tag: 'Tag-A', labels: {'Tag-A', 'Label-B'});

      expect(tree.logLines[0].labels, {'Tag-A', 'Label-A', 'Label-B'});
      expect(tree.logLines[1].labels, {'Tag-A', 'Label-B'});
    });

    test('Value semantic', () {
      Fimber.clearAll();
      final tree = MockTree(['D']);
      Fimber.plantTree(tree);

      final labels = {'Label-A'};
      Fimber.d('Test 1', labels: labels);
      labels.add('Label-B');
      Fimber.d('Test 2', labels: labels);

      expect(tree.logLines[0].labels, {'Label-A'});
      expect(tree.logLines[1].labels, {'Label-A', 'Label-B'});
    });
  });
}

class TestClass {
  TestClass() {
    Fimber.i("Logging from test class constructor.");
  }

  factory TestClass.factory1() {
    Fimber.i("Logging from factory method");
    return TestClass();
  }

  /// Throws some error
  void throwSomeError() {
    throw Exception("Test exception from TestClass");
  }

  @override
  String toString() {
    return "TestClass.instance";
  }
}

class AssertFormatTree extends CustomFormatTree {
  AssertFormatTree(String testLogFormat) : super(logFormat: testLogFormat);
  List<String> allLines = [];
  @override
  void printLine(String line, {String? level}) {
    super.printLine(line, level: level);
    allLines.add(line);
  }
}

class AssertTree extends LogTree {
  List<String> logLevels = [];
  String lastLogLine = "";
  List<String> allLines = [];

  AssertTree(this.logLevels);

  @override
  List<String> getLevels() {
    return logLevels;
  }

  @override
  void log(
    String level,
    String msg, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? context,
    Map<String, dynamic>? globalContext,
    required Set<String> labels,
  }) {
    tag = (tag ?? LogTree.getTag());
    var newLogLine =
        "$level:$tag\t$msg\t$ex\n${stacktrace?.toString().split('\n') ?? ""}";
    lastLogLine = newLogLine;
    allLines.add(newLogLine);
  }
}

class MockTree extends LogTree {
  List<String> logLevels = [];

  MockTree(this.logLevels);

  final List<CapturedLog> logLines = [];

  @override
  List<String> getLevels() {
    return logLevels;
  }

  @override
  void log(
    String level,
    String msg, {
    String? tag,
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? context,
    Map<String, dynamic>? globalContext,
    required Set<String> labels,
  }) {
    logLines.add(
      CapturedLog(
        level: level,
        msg: msg,
        tag: tag,
        ex: ex,
        stacktrace: stacktrace,
        context: context,
        globalContext: globalContext,
        labels: labels,
      ),
    );
  }
}

class CapturedLog {
  String level;
  String msg;
  String? tag;
  dynamic ex;
  StackTrace? stacktrace;
  Map<String, dynamic>? context;
  Map<String, dynamic>? globalContext;
  Set<String> labels;
  CapturedLog({
    required this.level,
    required this.msg,
    required this.tag,
    required this.ex,
    required this.stacktrace,
    required this.context,
    required this.globalContext,
    required this.labels,
  });
}
