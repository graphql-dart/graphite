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
  static const TokenKind enumKeyword =
      TokenKind._('<ENUM_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind extendKeyword =
      TokenKind._('<EXTEND_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind fragmentKeyword =
      TokenKind._('<FRAGMENT_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind implementsKeyword =
      TokenKind._('<IMPLEMENTS_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind inputKeyword =
      TokenKind._('<INPUT_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind interfaceKeyword =
      TokenKind._('<INTERFACE_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind mutationKeyword =
      TokenKind._('<MUTATION_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind onKeyword = TokenKind._('<ON_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind queryKeyword =
      TokenKind._('<QUERY_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind scalarKeyword =
      TokenKind._('<SCALAR_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind schemaKeyword =
      TokenKind._('<SCHEMA_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind subscriptionKeyword =
      TokenKind._('<SUBSCRIPTION_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind typeKeyword =
      TokenKind._('<TYPE_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind unionKeyword =
      TokenKind._('<UNION_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind directiveKeyword =
    TokenKind._('<DIRECTIVE_KEYWORD_OR_IDENTIFIER>');

  static const TokenKind nullKeyword =
  TokenKind._('<NULL_KEYWORD_OR_IDENTIFIER>');

  static const TokenKind trueKeyword =
      TokenKind._('<TRUE_KEYWORD_OR_IDENTIFIER>');
  static const TokenKind falseKeyword =
      TokenKind._('<FALSE_KEYWORD_OR_IDENTIFIER>');

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
      case directiveKeyword:
        return true;
    }

    return false;
  }

  static bool isIdentOrKeyword(TokenKind kind) =>
      kind == TokenKind.ident || isKeyword(kind);

  static TokenKind maybeKeywordOrIdentifier(String value) {
    if (_keywords.containsKey(value)) {
      return _keywords[value];
    }

    return TokenKind.ident;
  }
}

const Map<String, TokenKind> _keywords = {
  'directive': TokenKind.directiveKeyword,
  'enum': TokenKind.enumKeyword,
  'extend': TokenKind.extendKeyword,
  'fragment': TokenKind.fragmentKeyword,
  'implements': TokenKind.implementsKeyword,
  'input': TokenKind.inputKeyword,
  'interface': TokenKind.interfaceKeyword,
  'mutation': TokenKind.mutationKeyword,
  'null': TokenKind.nullKeyword,
  'on': TokenKind.onKeyword,
  'query': TokenKind.queryKeyword,
  'scalar': TokenKind.scalarKeyword,
  'schema': TokenKind.schemaKeyword,
  'subscription': TokenKind.subscriptionKeyword,
  'type': TokenKind.typeKeyword,
  'union': TokenKind.unionKeyword,
  'true': TokenKind.trueKeyword,
  'false': TokenKind.falseKeyword,
};

class Token {
  const Token(this.kind, this.spanning, {this.value});

  final TokenKind kind;
  final Spanning spanning;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is Token &&
      other.kind == kind &&
      other.spanning == spanning &&
      other.value == value;

  @override
  int get hashCode => kind.hashCode ^ spanning.hashCode ^ value.hashCode;

  @override
  String toString() => 'Token(kind=$kind, value=$value, spanning=$spanning)';
}
