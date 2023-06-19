import 'dart:convert';

import 'package:fimber/src/jsonify_context.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Passthrough simple json map', () {
    final input = {
      'string': 'string',
      'int': 1,
      'float': 1.42,
    };
    final output = jsonifyContext(input);

    expect(output['string'], input['string']);
    expect(output['int'], input['int']);
    expect(output['float'], input['float']);
    //{"string":"string","int":1,"float":1.42}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Passthrough nested json map', () {
    final Map<String, dynamic> input = {
      'map': {
        'string': 'string',
        'int': 1,
        'float': 1.42,
      }
    };
    final output = jsonifyContext(input);

    expect(output['map']['string'], input['map']['string']);
    expect(output['map']['int'], input['map']['int']);
    expect(output['map']['float'], input['map']['float']);
    //{"map":{"string":"string","int":1,"float":1.42}}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Passthrough nested simple list', () {
    final Map<String, dynamic> input = {
      'stringList': ['string'],
      'intList': [1],
      'floatList': [1.42],
    };
    final output = jsonifyContext(input);

    expect(output['stringList'][0], input['stringList'][0]);
    expect(output['intList'][0], input['intList'][0]);
    expect(output['floatList'][0], input['floatList'][0]);
    //{"stringList":["string"],"intList":[1],"floatList":[1.42]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Passthrough nested map in list', () {
    final Map<String, dynamic> input = {
      'list': [
        {
          'string': 'string',
          'int': 1,
          'float': 1.42,
        }
      ]
    };
    final output = jsonifyContext(input);

    expect(output['list'][0]['string'], input['list'][0]['string']);
    expect(output['list'][0]['int'], input['list'][0]['int']);
    expect(output['list'][0]['float'], input['list'][0]['float']);
    //{"list":[{"string":"string","int":1,"float":1.42}]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Passthrough nested list in map', () {
    final Map<String, dynamic> input = {
      'list': [
        {
          'stringList': ['string'],
          'intList': [1],
          'floatList': [1.42],
        }
      ]
    };
    final output = jsonifyContext(input);

    expect(
        output['list'][0]['stringList'][0], input['list'][0]['stringList'][0]);
    expect(output['list'][0]['intList'][0], input['list'][0]['intList'][0]);
    expect(output['list'][0]['floatList'][0], input['list'][0]['floatList'][0]);
    //{"list":[{"stringList":["string"],"intList":[1],"floatList":[1.42]}]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Passthrough nested list in list', () {
    final Map<String, dynamic> input = {
      'list': [
        [1],
        ['string'],
        [1.12]
      ]
    };
    final output = jsonifyContext(input);

    expect(output['list'][0], input['list'][0]);
    expect(output['list'][1], input['list'][1]);
    expect(output['list'][2], input['list'][2]);
    //{"list":[[1],["string"],[1.12]]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Convert incompatible object to string', () {
    final obj = DummyObject();
    final input = {
      'object': obj,
    };
    final output = jsonifyContext(input);

    expect(output['object'], obj.toString());
    //{"object":"Instance of 'DummyObject'"}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Convert incompatible object in list', () {
    final obj = DummyObject();
    final Map<String, dynamic> input = {
      'list': [obj],
    };
    final output = jsonifyContext(input);

    expect(output['list'][0], obj.toString());
    //{"list":["Instance of 'DummyObject'"]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Convert incompatible object in map', () {
    final obj = DummyObject();
    final Map<String, dynamic> input = {
      'map': {
        'object': obj,
      }
    };
    final output = jsonifyContext(input);

    expect(output['map']['object'], obj.toString());
    //{"map":{"object":"Instance of 'DummyObject'"}}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Convert hybrid list', () {
    final obj = DummyObject();
    final Map<String, dynamic> input = {
      'list': [1, 'string', obj]
    };
    final output = jsonifyContext(input);

    expect(output['list'][0], 1);
    expect(output['list'][1], 'string');
    expect(output['list'][2], obj.toString());
    //{"list":[1,"string","Instance of 'DummyObject'"]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Convert nested hybrid list', () {
    final obj = DummyObject();
    final Map<String, dynamic> input = {
      'list': [
        [1, 'string', obj],
        [1, 'string', obj],
      ],
    };
    final output = jsonifyContext(input);

    expect(output['list'][1][0], 1);
    expect(output['list'][1][1], 'string');
    expect(output['list'][1][2], obj.toString());
    //{"list":[[1,"string","Instance of 'DummyObject'"],[1,"string","Instance of 'DummyObject'"]]}
    expect(jsonEncode(output).isNotEmpty, true);
  });

  test('Keep nulls', () {
    final Map<String, dynamic> input = {
      'key': null,
      'map': {
        'key': null,
        'list': [null],
      },
      'list': [
        null,
        {'key': null}
      ]
    };
    final output = jsonifyContext(input);
    expect(output.containsKey('key'), false);
    expect(output['map'] is Map && !(output['map'] as Map).containsKey('key'),
        true);
    expect(output['map']['list'][0], null);
    expect(output['list'][0], null);
    expect(
        output['list'][1] is Map &&
            !(output['list'][1] as Map).containsKey('key'),
        true);
    //{"map":{"list":[null]},"list":[null,{}]}
    expect(jsonEncode(output).isNotEmpty, true);
  });
}

class DummyObject {}
