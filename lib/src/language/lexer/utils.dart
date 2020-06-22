/// Tests whether [code] is valid source character.
///
/// Valid source characters: `[\u0009\u000A\u000D\u0020-\uFFFF]`
///
/// https://graphql.github.io/graphql-spec/draft/#SourceCharacter
bool isValidSourceChar(int code) =>
    code >= 0x20 || code == 0x09 || code == 0x0a || code == 0x0d;

/// Test whether [code] is a digit (`[0-9]`).
bool isDigit(int code) =>
    code >= 0x30 /* 0 */ &&
    code <= 0x39 /* 9 */ &&
    code != -1 /* EOF specific code */;

/// Test whether [code] is a letter (`[A-Za-z]`).
bool isLetter(int code) =>
    (code >= 0x41 /* A */ && code <= 0x5a /* Z */) ||
    (code >= 0x61 /* a */ && code <= 0x7a /* z */);

/// Normalizes block string indentation.
///
/// https://graphql.github.io/graphql-spec/draft/#BlockStringValue()
String formatBlockStringValue(String rawValue) {
  if (rawValue.isEmpty) {
    return '';
  }

  final lines = rawValue.split('\n');
  final commonIndent = _computeCommonIndent(lines);
  final l = lines.length;

  if (commonIndent > 0) {
    for (int i = 1; i < l; i++) {
      if (commonIndent < lines[i].length) {
        lines[i] = lines[i].substring(commonIndent);
      }
    }
  }

  return _normalizeLinesToBlockString(lines);
}

String getUnexpectedCharExceptionMessage(int code) {
  if (!isValidSourceChar(code)) {
    return 'Invalid source character: "${String.fromCharCode(code)}"';
  }

  return 'Unexpected source character: "${String.fromCharCode(code)}"';
}

String _normalizeLinesToBlockString(List<String> lines) {
  int count;

  for (count = 0;
      (count < lines.length) && _isBlankLine(lines[count]);
      count++) {}

  if (count > 0) {
    lines.removeRange(0, count);
  }

  for (count = lines.length - 1;
      (count > 0) && _isBlankLine(lines[count]);
      count--) {}

  lines.removeRange(count + 1, lines.length);

  return lines.join('\n');
}

int _computeCommonIndent(List<String> lines) {
  final totalLines = lines.length;
  int commonIndent = 0;
  int indent;

  for (int i = 1; i < totalLines; i++) {
    indent = _countLeadingWhitespace(lines[i]);

    if (indent == lines[i].length) {
      continue;
    }

    if (commonIndent == 0 || commonIndent > indent) {
      commonIndent = indent;

      if (commonIndent == 0) {
        return 0;
      }
    }
  }

  return commonIndent;
}

int _countLeadingWhitespace(String line) {
  final l = line.length;
  int indent = 0;

  for (int i = 0; i < l; i++) {
    final code = line[i].codeUnitAt(0);

    if (code != 0x09 /* \t */ && code != 0x20 /* ` ` */) {
      break;
    }

    indent++;
  }

  return indent;
}

bool _isBlankLine(String line) =>
    line.isEmpty || _countLeadingWhitespace(line) == line.length;
