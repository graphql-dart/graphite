import 'dart:math' as math;

import 'package:graphite/token.dart' show Source, Spanning;

final _newline = RegExp('\r\n|[\r\n]');

/// An error thrown when syntax error is occurred.
class SyntaxException implements Exception {
  SyntaxException(
      this.message,
      this.source,
      this.spanning,
      // ignore: avoid_positional_boolean_parameters
      this._shouldHighlightSource)
      : super();

  final String message;
  final Source source;
  final Spanning spanning;
  final bool _shouldHighlightSource;

  String get highlight {
    final lines = source.body.split(_newline);
    final startLine = spanning.start.line - 1;
    final endLine = spanning.end.line - 1;
    final start = math.max(startLine - 1, 0);
    final end = math.min(endLine, lines.length);
    final diff = end - start;
    final buffer = StringBuffer();

    if (diff > 0) {
      for (int i = 0; i <= diff; i++) {
        // code
      }
    }

    return buffer.toString();
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('SyntaxException: ')
      ..writeln(message);

    if (_shouldHighlightSource) {
      buffer.writeln(highlight);
    }

    return buffer.toString();
  }
}
