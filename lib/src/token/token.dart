// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/token.dart' show Spanning;

class TokenKind {
  const TokenKind._(this._value, this._name);

  final int _value;
  final String _name;

  @override
  int get hashCode => _value;

  @override
  bool operator ==(Object other) =>
      other is TokenKind && other._value == _value;

  @override
  String toString() => 'TokenKind(value=$_name)';

  static const TokenKind eof = TokenKind._(-1, '<EOF>');
  static const TokenKind comment = TokenKind._(0, '<COMMENT>');

  static const TokenKind blockStringValue =
      TokenKind._(1, '<BLOCK_STRING_VALUE>');
  static const TokenKind booleanValue = TokenKind._(2, '<BOOLEAN_VALUE>');
  static const TokenKind floatValue = TokenKind._(3, '<FLOAT_VALUE>');
  static const TokenKind integerValue = TokenKind._(4, '<INTEGER_VALUE>');
  static const TokenKind stringValue = TokenKind._(4, '<STRING_VALUE>');

  static const TokenKind bang = TokenKind._(100, '!');
  static const TokenKind dollar = TokenKind._(101, '\$');
  static const TokenKind parenl = TokenKind._(102, '(');
  static const TokenKind parenr = TokenKind._(103, ')');
  static const TokenKind spread = TokenKind._(104, '...');
  static const TokenKind colon = TokenKind._(105, ':');
  static const TokenKind eq = TokenKind._(106, '=');
  static const TokenKind at = TokenKind._(107, '@');
  static const TokenKind bracel = TokenKind._(108, '[');
  static const TokenKind bracer = TokenKind._(109, ']');
  static const TokenKind bracketl = TokenKind._(110, '{');
  static const TokenKind pipe = TokenKind._(111, '|');
  static const TokenKind bracketr = TokenKind._(112, '}');

  static const TokenKind ident = TokenKind._(200, '<IDENTIFIER>');
  static const TokenKind enumKeyword = TokenKind._(201, 'enum');
  static const TokenKind extendKeyword = TokenKind._(202, 'extend');
  static const TokenKind fragmentKeyword = TokenKind._(203, 'fragment');
  static const TokenKind implementsKeyword = TokenKind._(204, 'implements');
  static const TokenKind inputKeyword = TokenKind._(205, 'input');
  static const TokenKind interfaceKeyword = TokenKind._(206, 'interface');
  static const TokenKind mutationKeyword = TokenKind._(207, 'mutation');
  static const TokenKind nullKeyword = TokenKind._(208, 'null');
  static const TokenKind onKeyword = TokenKind._(209, 'on');
  static const TokenKind queryKeyword = TokenKind._(210, 'query');
  static const TokenKind scalarKeyword = TokenKind._(211, 'scalar');
  static const TokenKind schemaKeyword = TokenKind._(212, 'schema');
  static const TokenKind subscriptionKeyword = TokenKind._(213, 'subscription');
  static const TokenKind typeKeyword = TokenKind._(214, 'type');
  static const TokenKind unionKeyword = TokenKind._(215, 'union');

  /// Tests whether [kind] is some keyword kind.
  static bool isKeyword(TokenKind kind) =>
      kind == enumKeyword ||
      kind == extendKeyword ||
      kind == fragmentKeyword ||
      kind == implementsKeyword ||
      kind == inputKeyword ||
      kind == interfaceKeyword ||
      kind == mutationKeyword ||
      kind == nullKeyword ||
      kind == onKeyword ||
      kind == queryKeyword ||
      kind == scalarKeyword ||
      kind == schemaKeyword ||
      kind == subscriptionKeyword ||
      kind == typeKeyword ||
      kind == unionKeyword;
}

class Token {
  const Token(this.kind, this.spanning, {this.value});

  final TokenKind kind;
  final Spanning spanning;
  final String value;

  @override
  String toString() => 'Token(kind=$kind, value=$value, spanning=$spanning)';
}
