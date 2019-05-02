// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/token.dart' show Spanning;

class TokenKind {
  const TokenKind._(this._name);

  final String _name;

  @override
  String toString() => 'TokenKind(value=$_name)';

  static const TokenKind eof = TokenKind._('<EOF>');
  static const TokenKind comment = TokenKind._('<COMMENT>');

  static const TokenKind blockStringValue = TokenKind._('<BLOCK_STRING_VALUE>');
  static const TokenKind booleanValue = TokenKind._('<BOOLEAN_VALUE>');
  static const TokenKind floatValue = TokenKind._('<FLOAT_VALUE>');
  static const TokenKind integerValue = TokenKind._('<INTEGER_VALUE>');
  static const TokenKind stringValue = TokenKind._('<STRING_VALUE>');

  static const TokenKind bang = TokenKind._('!');
  static const TokenKind dollar = TokenKind._('\$');
  static const TokenKind amp = TokenKind._('&');
  static const TokenKind parenl = TokenKind._('(');
  static const TokenKind parenr = TokenKind._(')');
  static const TokenKind spread = TokenKind._('...');
  static const TokenKind colon = TokenKind._(':');
  static const TokenKind eq = TokenKind._('=');
  static const TokenKind at = TokenKind._('@');
  static const TokenKind bracel = TokenKind._('[');
  static const TokenKind bracer = TokenKind._(']');
  static const TokenKind bracketl = TokenKind._('{');
  static const TokenKind pipe = TokenKind._('|');
  static const TokenKind bracketr = TokenKind._('}');

  static const TokenKind ident = TokenKind._('<IDENTIFIER>');
  static const TokenKind enumKeyword = TokenKind._('enum');
  static const TokenKind extendKeyword = TokenKind._('extend');
  static const TokenKind fragmentKeyword = TokenKind._('fragment');
  static const TokenKind implementsKeyword = TokenKind._('implements');
  static const TokenKind inputKeyword = TokenKind._('input');
  static const TokenKind interfaceKeyword = TokenKind._('interface');
  static const TokenKind mutationKeyword = TokenKind._('mutation');
  static const TokenKind nullKeyword = TokenKind._('null');
  static const TokenKind onKeyword = TokenKind._('on');
  static const TokenKind queryKeyword = TokenKind._('query');
  static const TokenKind scalarKeyword = TokenKind._('scalar');
  static const TokenKind schemaKeyword = TokenKind._('schema');
  static const TokenKind subscriptionKeyword = TokenKind._('subscription');
  static const TokenKind typeKeyword = TokenKind._('type');
  static const TokenKind unionKeyword = TokenKind._('union');

  /// Tests whether [kind] is a keyword kind.
  static bool isKeyword(TokenKind kind) {
    switch (kind) {
      case enumKeyword:
      case extendKeyword:
      case fragmentKeyword:
      case implementsKeyword:
      case inputKeyword:
      case interfaceKeyword:
      case mutationKeyword:
      case nullKeyword:
      case onKeyword:
      case queryKeyword:
      case scalarKeyword:
      case schemaKeyword:
      case subscriptionKeyword:
      case typeKeyword:
      case unionKeyword:
        return true;
    }

    return false;
  }
}

class Token {
  const Token(this.kind, this.spanning, {this.value});

  final TokenKind kind;
  final Spanning spanning;
  final String value;

  @override
  String toString() => 'Token(kind=$kind, value=$value, spanning=$spanning)';

  /// Tests whether [token] is identifier.
  static bool isIdent(Token token) =>
      token.kind == TokenKind.ident || isKeyword(token);

  /// Tests whether [token] is a keyword.
  static bool isKeyword(Token token) => TokenKind.isKeyword(token.kind);
}
