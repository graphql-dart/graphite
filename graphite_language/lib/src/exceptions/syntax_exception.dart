import 'dart:math' as math;

import 'package:graphite_language/token.dart' show Source, Spanning;
import 'package:meta/meta.dart' show required;

final _newline = RegExp('\r\n|[\r\n]');

int _countDigit(int n) {
  int nn = n;
  int c = 0;

  while (nn > 1) {
    nn ~/= 10;
    c++;
  }

  return c;
}

String _padLeft(int n, {String string, String char = ' '}) {
  final buffer = StringBuffer();

  for (int i = string?.length ?? 0; i < n; i++) {
    buffer.write(char);
  }

  if (string != null) {
    buffer.write(string);
  }

  return buffer.toString();
}

String getPrintLine({
  @required int gutter,
  @required int commonIdent,
  @required String line,
}) =>
    '${_padLeft(commonIdent, string: gutter.toString())}| $line';

/// An error thrown when syntax error is occurred.
class SyntaxException implements Exception {
  SyntaxException(this.message, this.source, this.spanning,
      // ignore: avoid_positional_boolean_parameters
      {this.shouldHighlightSource})
      : super();

  final String message;
  final Source source;
  final Spanning spanning;
  final bool shouldHighlightSource;

  String get highlighting {
    final lines = source.body.split(_newline);
    final lineNum = spanning.start.line - 1;
    final start = spanning.start.column;
    final end = spanning.end.column;
    final buffer = StringBuffer();
    final digitCount = _countDigit(math.min(spanning.start.line, lines.length));

    if (lineNum > 0) {
      buffer.writeln(getPrintLine(
        commonIdent: digitCount,
        gutter: spanning.start.line - 1,
        line: lines[lineNum - 1],
      ));
    }

    buffer.writeln(getPrintLine(
      commonIdent: digitCount,
      gutter: spanning.start.line,
      line: lines[lineNum],
    ));

    // Error code highlight
    buffer.write(_padLeft(digitCount + start));
    buffer.writeln(_padLeft(end - start, char: '^'));

    if (lineNum < lines.length - 1) {
      buffer.writeln(getPrintLine(
        commonIdent: digitCount,
        gutter: spanning.start.line + 1,
        line: lines[lineNum + 1],
      ));
    }

    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('SyntaxException: ')
      ..writeln(message);

    if (shouldHighlightSource) {
      buffer.writeln(highlighting);
    }

    return buffer.toString();
  }
}
