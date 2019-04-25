// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/token.dart' show Source, Token;

import 'lexer_impl.dart';

abstract class Lexer {
  factory Lexer(Source source, {bool shouldParseComments}) = LexerImpl;

  Iterable<Token> lex();
}
