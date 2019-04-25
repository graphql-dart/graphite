// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

/// Tests whether [char] is valid source character.
///
/// Valid source characters: `[\u0009\u000A\u000D\u0020-\uFFFF]`
///
/// https://graphql.github.io/graphql-spec/draft/#SourceCharacter
bool isValidSourceChar(int char) =>
    char >= 0x20 || char == 0x09 || char == 0x0a || char == 0x0d;

/// Test whether [char] is a digit (`[0-9]`).
bool isDigit(int char) =>
    char >= 0x30 /* 0 */ &&
    char <= 0x39 /* 9 */ &&
    char != -1 /* EOF specific code */;

/// Test whether [char] is a letter (`[A-Za-z]`).
bool isLetter(int char) =>
    (char >= 0x41 /* A */ && char <= 0x5a /* Z */) ||
    (char >= 0x61 /* a */ && char <= 0x7a /* z */);

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
