import 'dart:convert';

Map<String, dynamic> jsonifyContext(Map<String, dynamic> context) {
  final json = _jsonifyMap(context);
  assert(jsonEncode(json).isNotEmpty == true, 'Context is not json compatible');
  return json;
}

Map<String, dynamic> _jsonifyMap(Map<String, dynamic> context) {
  final Map<String, dynamic> json = {};
  json.addEntries(context.entries
      .map(_jsonifyEntry)
      .whereType<MapEntry<String, dynamic>>()
      .toList());
  return json;
}

MapEntry<String, dynamic>? _jsonifyEntry(MapEntry<String, dynamic> entry) {
  if (entry.value == null) {
    return null;
  }

  final String key = entry.key;
  final dynamic value = entry.value;
  if (value is num || value is String) {
    return entry;
  } else if (value is Map<String, dynamic>) {
    return MapEntry(key, _jsonifyMap(value));
  } else if (value is List<dynamic>) {
    final List<dynamic> list = value;
    return MapEntry(key, list.map(_jsonifyEntryValue).toList());
  }
  return MapEntry(key, value.toString());
}

dynamic _jsonifyEntryValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num || value is String) {
    return value;
  } else if (value is Map<String, dynamic>) {
    return _jsonifyMap(value);
  } else if (value is List<dynamic>) {
    return value.map(_jsonifyEntryValue).toList();
  }
  return value.toString();
}
