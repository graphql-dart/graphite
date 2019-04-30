// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/token.dart';
import 'package:graphite_language/errors.dart';

import 'package:graphite_language/src/lexer/lexer.dart';
import 'package:graphite_language/src/lexer/utils.dart';

const _punctuators = <int, TokenKind>{
  0x21: TokenKind.bang, // !
  0x24: TokenKind.dollar, // $
  0x28: TokenKind.parenl, // (
  0x29: TokenKind.parenr, // )
  0x3a: TokenKind.colon, // :
  0x3d: TokenKind.eq, // =
  0x40: TokenKind.at, // @
  0x5b: TokenKind.bracel, // [
  0x5d: TokenKind.bracer, // ]
  0x7b: TokenKind.bracketl, // {
  0x7c: TokenKind.pipe, // |
  0x7d: TokenKind.bracketr, // }
};

const _keywords = <String, TokenKind>{
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
};

class LexerImpl implements Lexer {
  LexerImpl(this._source, {this.shouldParseComments = false})
      : _offset = 0,
        _line = 1,
        _column = 1;

  final bool shouldParseComments;
  final Source _source;
  int _offset;
  int _line;
  int _column;

  String get _body => _source.body;

  /// Test whether it reaches end of the file.
  bool get _isEOF => _peek() == -1;

  int _peek([int offset = 0]) {
    if (_offset + offset < _body.length) {
      return _body.codeUnitAt(_offset + offset);
    }

    return -1;
  }

  void _next() {
    final code = _peek();

    if (code == -1) {
      return;
    }

    _offset++;
    _column++;
  }

  bool _scanEol() {
    if (_peek() == 0x0d /* \r */) {
      if (_peek(1) == 0x0a /* \n */) {
        _next();
      }

      _line++;
      _column = 0;

      return true;
    } else if (_peek() == 0x0a /* \n */) {
      _line++;
      _column = 0;

      return true;
    }

    return false;
  }

  /// Skips all insignificant characters.
  ///
  /// https://facebook.github.io/graphql/draft/#sec-Source-Text.Ignored-Tokens
  void skipWhitespace() {
    int code;

    while (!_isEOF) {
      code = _peek();

      if (code != 0xfeff /* BOM */ &&
          code != 0x09 /* \t */ &&
          code != 0x20 /* ` ` */ &&
          code != 0x2c /* , */ &&
          !_scanEol()) {
        break;
      }

      // skip last line terminator.
      _next();
    }
  }

  /// Consumes comment from the source.
  ///
  /// Comment starts with `#` and ends on newline or EOF.
  /// https://facebook.github.io/graphql/draft/#sec-Comments
  Token scanComment() {
    final start = Position(offset: _offset, line: _line, column: _column);
    final buffer = StringBuffer();

    // skip leading `#`.
    _next();

    while (!_isEOF) {
      if (_scanEol()) {
        // skip last line terminator.
        _next();

        break;
      }

      buffer.writeCharCode(_peek());

      _next();
    }

    final end = Position(offset: _offset, line: _line, column: _column);

    return Token(TokenKind.comment, Spanning(start, end),
        value: buffer.toString());
  }

  String _scanDigits() {
    final buffer = StringBuffer();

    do {
      if (isDigit(_peek())) {
        buffer.writeCharCode(_peek());
      } else {
        break;
      }

      _next();
    } while (!_isEOF);

    return buffer.toString();
  }

  /// Consumes integer or float number.
  /// Integer: `-?(0|[1-9][0-9]*)`
  /// Float:   `-?(0|[1-9][0-9]*)(\.[0-9]+)?((E|e)(+|-)?[0-9]+)?`
  ///
  /// https://graphql.github.io/graphql-spec/draft/#IntValue
  /// https://graphql.github.io/graphql-spec/draft/#FloatValue
  Token scanNumber() {
    final buffer = StringBuffer();
    final start = Position(offset: _offset, line: _line, column: _column);
    bool isFloat = false;

    if (_peek() == 0x2d /* - */) {
      buffer.writeCharCode(_peek());
      _next();
    }

    if (_peek() == 0x30 /* 0 */) {
      if (isDigit(_peek(1))) {
        throw SyntaxError('Unexpected digit after `0`!');
      }

      buffer.writeCharCode(_peek());
      _next();
    } else if (isDigit(_peek())) {
      buffer.write(_scanDigits());
    } else {
      throw SyntaxError('Expected digit after `-`!');
    }

    // Read fraction part if any.
    // https://graphql.github.io/graphql-spec/draft/#FractionalPart
    if (_peek() == 0x2e /* . */) {
      isFloat = true;

      buffer.writeCharCode(_peek());
      _next();

      if (!isDigit(_peek())) {
        throw SyntaxError('Expected digit after `.`!');
      }

      buffer.write(_scanDigits());
    }

    // Read exponent part if any.
    // https://graphql.github.io/graphql-spec/draft/#ExponentPart
    if (_peek() == 0x45 /* E */ || _peek() == 0x65 /* e */) {
      isFloat = true;

      buffer.writeCharCode(_peek());
      _next();

      if (_peek() == 0x2b /* + */ || _peek() == 0x2d /* - */) {
        buffer.writeCharCode(_peek());
        _next();
      }

      if (isDigit(_peek())) {
        buffer.write(_scanDigits());
      } else {
        throw SyntaxError('Expected digit after exponent part!');
      }
    }

    final end = Position(offset: _offset, line: _line, column: _column);

    return Token(
      isFloat ? TokenKind.floatValue : TokenKind.integerValue,
      Spanning(start, end),
      value: buffer.toString(),
    );
  }

  int _scanEscapedUnicode() {
    final buffer = StringBuffer();
    int code;

    // Look if enough bytes are provided.
    if (_peek(4) == -1) {
      throw SyntaxError('Unterminated string!');
    }

    for (int _ = 0; _ < 4; _++) {
      _next();
      code = _peek();

      if (isDigit(code) ||
          (isLetter(code) && (code <= 0x46 /* F */ || code <= 0x66 /* f */))) {
        buffer.writeCharCode(code);

        continue;
      }

      throw SyntaxError('Unknown unicode escape sequence!');
    }

    code = int.tryParse(buffer.toString(), radix: 16);

    if (code != null) {
      return String.fromCharCode(code).codeUnitAt(0);
    }

    throw SyntaxError('Unknown unicode escape sequence!');
  }

  /// https://facebook.github.io/graphql/draft/#sec-String-Value
  Token scanString() {
    final start = Position(offset: _offset, line: _line, column: _column);
    final buffer = StringBuffer();
    int code;

    // skip leading quote.
    _next();

    while (!_isEOF) {
      code = _peek();

      if (!isValidSourceChar(code)) {
        throw SyntaxError('Invalid source character!');
      }

      if (code == 0x22 /* " */) {
        _next();

        final end = Position(offset: _offset, line: _line, column: _column);

        return Token(TokenKind.stringValue, Spanning(start, end),
            value: buffer.toString());
      } else if (code == 0x5c /* \ */) {
        _next();
        code = _peek();

        switch (code) {
          case 0x22 /* " */ :
            buffer.writeCharCode(0x22);
            break;
          case 0x5c /* \ */ :
            buffer.writeCharCode(0x5c);
            break;
          case 0x2f /* / */ :
            buffer.writeCharCode(0x2f);
            break;
          case 0x62 /* b */ :
            buffer.writeCharCode(0x08);
            break;
          case 0x66 /* f */ :
            buffer.writeCharCode(0x0c);
            break;
          case 0x6e /* n */ :
            buffer.writeCharCode(0x0a);
            break;
          case 0x72 /* r */ :
            buffer.writeCharCode(0x0d);
            break;
          case 0x74 /* t */ :
            buffer.writeCharCode(0x09);
            break;
          case 0x75 /* u */ :
            buffer.writeCharCode(_scanEscapedUnicode());
            break;

          default:
            throw SyntaxError('Invalid character escape sequence!');
        }
      } else if (code == 0x0a /* \n */ || code == 0x0d /* \r */) {
        throw SyntaxError('Unterminated string!');
      } else {
        buffer.writeCharCode(code);
      }

      _next();
    }

    throw SyntaxError('Unterminated string!');
  }

  Token scanBlockString() {
    final start = Position(offset: _offset, line: _line, column: _column);
    final buffer = StringBuffer();
    int code;

    // skipping leading """
    _next();
    _next();
    _next();

    while (!_isEOF) {
      code = _peek();

      if (!isValidSourceChar(code)) {
        throw SyntaxError('Invalid source character!');
      }

      if (code == 0x5c /* \ */ &&
          _peek(1) == 0x22 /* " */ &&
          _peek(2) == 0x22 &&
          _peek(3) == 0x22) {
        buffer.writeCharCode(0x22 /* " */);
        buffer.writeCharCode(0x22);
        buffer.writeCharCode(0x22);

        // skip escaped `"""`.
        _next();
        _next();
        _next();
      } else if (code == 0x22 /* " */ && _peek(1) == 0x22 && _peek(2) == 0x22) {
        // skip closing `"""`.
        _next();
        _next();
        _next();

        final end = Position(offset: _offset, line: _line, column: _column);
        final value = formatBlockStringValue(buffer.toString());

        return Token(TokenKind.blockStringValue, Spanning(start, end),
            value: value);
      } else if (_scanEol()) {
        buffer.writeCharCode(0x0a /* \n */);
      } else {
        buffer.writeCharCode(code);
      }

      _next();
    }

    throw SyntaxError('Unterminated string!');
  }

  /// Consumes identifier or a keyword such as operations, fields, etc.
  /// `[_A-Za-z][_0-9A-Za-z]*`.
  ///
  /// https://facebook.github.io/graphql/draft/#sec-Names
  Token scanIdent() {
    final buffer = StringBuffer();
    final start = Position(offset: _offset, line: _line, column: _column);
    int code = _peek();

    if (isLetter(code) || code == 0x5f /* _ */) {
      while (!_isEOF) {
        code = _peek();

        if (!isLetter(code) && !isDigit(code) && code != 0x5f) {
          break;
        }

        buffer.writeCharCode(code);
        _next();
      }

      final value = buffer.toString();
      final end = Position(offset: _offset, line: _line, column: _column);
      TokenKind kind = TokenKind.ident;

      if (_keywords.containsKey(value)) {
        kind = _keywords[value];
      }

      return Token(kind, Spanning(start, end),
          value: TokenKind.isKeyword(kind) ? null : value.toString());
    }

    throw SyntaxError('Unexpected source character $code in identifier!');
  }

  Token scanToken() {
    skipWhitespace();

    final code = _peek();

    if (code == -1 /* EOF */) {
      final pos = Position(offset: _offset, line: _line, column: _column);

      return Token(TokenKind.eof, Spanning(pos, pos));
    } else if (code < 0x20 && code != 0x09 && code != 0x0a && code != 0x0d) {
      throw SyntaxError('Invalid source character $code');
    } else if (code == 0x23 /* # */) {
      return scanComment();
    } else if (_punctuators.containsKey(code)) {
      final kind = _punctuators[code];
      final start = Position(offset: _offset, line: _line, column: _column);

      _next();

      final end = Position(offset: _offset, line: _line, column: _column);

      return Token(kind, Spanning(start, end));
    } else if (code == 0x2d /* - */ || isDigit(code)) {
      return scanNumber();
    } else if (isLetter(code) || code == 0x5f /* _ */) {
      return scanIdent();
    } else if (code == 0x2e /* . */) {
      if (_peek(1) == 0x2e && _peek(2) == 0x2e) {
        final start = Position(offset: _offset, line: _line, column: _column);

        // skip first two .. second skipped on iteration.
        _next();
        _next();

        final end =
            Position(offset: _offset + 1, line: _line, column: _column + 1);

        return Token(TokenKind.spread, Spanning(start, end));
      }

      throw SyntaxError('Unexpected source character $code!');
    } else if (code == 0x22 /* " */) {
      if (_peek(1) == 0x22 && _peek(2) == 0x22) {
        return scanBlockString();
      }

      return scanString();
    }

    throw SyntaxError('Unexpected source character $code!');
  }

  @override
  Iterable<Token> lex() sync* {
    Token token;

    do {
      token = scanToken();

      if (token.kind == TokenKind.comment) {
        if (shouldParseComments) {
          yield token;
        }
      } else {
        yield token;
      }
    } while (token.kind != TokenKind.eof);
  }
}
