// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'dart:math' as math;

import 'package:graphite_language/token.dart' show Source, Spanning;

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
