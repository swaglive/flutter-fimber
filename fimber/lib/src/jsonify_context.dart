import 'dart:convert';

Map<String, dynamic> jsonifyContext(Map<String, dynamic> context) {
  final json = _jsonifyMap(context);
  assert(jsonEncode(json).isNotEmpty == true, 'Context is not json compatible');
  return json;
}

Map<String, dynamic> _jsonifyMap(Map<String, dynamic> context) {
  final Map<String, dynamic> json = {};
  json.addEntries(context.entries.map(_jsonifyEntry).toList());
  return json;
}

MapEntry<String, dynamic> _jsonifyEntry(MapEntry<String, dynamic> entry) {
  if (entry.value == null || entry.value is num || entry.value is String) {
    return entry;
  } else if (entry.value is Map<String, dynamic>) {
    return MapEntry(entry.key, _jsonifyMap(entry.value));
  } else if (entry.value is List<dynamic>) {
    final List<dynamic> list = entry.value;
    return MapEntry(entry.key, list.map(_jsonifyEntryValue).toList());
  }
  return MapEntry(entry.key, entry.value.toString());
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
