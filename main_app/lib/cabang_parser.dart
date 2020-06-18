class CabangParseResult {
  final Map<String, String> keyToBody;
  final Map<String, List<String>> parentToKeys;

  CabangParseResult(this.keyToBody, this.parentToKeys);
}

parseCabang(List<String> lines) {
  final keyToBody = <String, String>{};
  final parentToKeys = <String, List<String>>{};

  String mode = 'key';
  String currentKey = '';
  String bodySoFar = '';

  commit() {
    if (bodySoFar.isNotEmpty) {
      final currentParent = currentKey.substring(0, currentKey.lastIndexOf('->'));
      var keys = parentToKeys[currentParent];
      if (keys == null) {
        keys = <String>[];
      }
      keys.add(currentKey);
      parentToKeys[currentParent] = keys;
      keyToBody[currentKey] = bodySoFar;
      currentKey = '';
      bodySoFar = '';
    }
  }

  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    while (true) {
      if (mode == 'key') {
        if (line.startsWith('*')) {
          final lastPath = line.substring(1).trim();
          currentKey += '->$lastPath';
          break;
        } else {
          mode = 'body';
        }
      } else if (mode == 'body') {
        if (line.startsWith('*')) {
          commit();
          mode = 'key';
        } else {
          bodySoFar += line + '\n';
          break;
        }
      }
    }
  }

  if (mode == 'body') {
    commit();
  }

  return CabangParseResult(keyToBody, parentToKeys);
}
