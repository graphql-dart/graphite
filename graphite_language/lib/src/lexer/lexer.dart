import 'package:graphite_language/token.dart';
import 'package:graphite_language/exceptions.dart';

import 'package:graphite_language/src/lexer/utils.dart';

const Map<int, TokenKind> _punctuators = {
  0x21: TokenKind.bang, // !
  0x24: TokenKind.dollar, // $
  0x26: TokenKind.amp, // &
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

class Lexer {
  Lexer(this.source,
      {this.shouldHighlightSourceInExceptions = false,
      this.shouldParseComments = false})
      : _offset = 0,
        _line = 1,
        _column = 1;

  final Source source;
  final bool shouldParseComments;
  final bool shouldHighlightSourceInExceptions;

  int _offset;
  int _line;
  int _column;

  String get _body => source.body;

  Position get _position =>
      Position(offset: _offset, line: _line, column: _column);

  /// Test whether parser_old reaches end of the file.
  bool get _isEOF => _peek() == -1;

  SyntaxException _createSyntaxException(String message, Spanning spanning) =>
      SyntaxException(
        message,
        source,
        spanning,
        shouldHighlightSource: shouldHighlightSourceInExceptions,
      );

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
  void _skipWhitespace() {
    int code;

    while (!_isEOF) {
      code = _peek();

      if (!isValidSourceChar(code)) {
        throw _createSyntaxException(getUnexpectedCharExceptionMessage(code),
            Spanning.zeroWidth(_position));
      }

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
  Token _scanComment() {
    final start = _position;
    StringBuffer buffer;

    if (shouldParseComments) {
      buffer = StringBuffer();
    }

    // skip leading `#`.
    _next();

    while (!_isEOF) {
      if (_scanEol()) {
        // skip last line terminator.
        _next();

        break;
      }

      buffer?.writeCharCode(_peek());

      _next();
    }

    return Token(TokenKind.comment, Spanning(start, _position),
        value: shouldParseComments ? buffer.toString() : null);
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
  Token _scanNumber() {
    final buffer = StringBuffer();
    final start = _position;
    bool isFloat = false;

    if (_peek() == 0x2d /* - */) {
      buffer.writeCharCode(_peek());
      _next();
    }

    if (_peek() == 0x30 /* 0 */) {
      if (isDigit(_peek(1))) {
        _next();

        throw _createSyntaxException(getUnexpectedCharExceptionMessage(_peek()),
            Spanning(start, _position));
      }

      buffer.writeCharCode(_peek());
      _next();
    } else if (isDigit(_peek())) {
      buffer.write(_scanDigits());
    } else {
      throw _createSyntaxException(getUnexpectedCharExceptionMessage(_peek()),
          Spanning(start, _position));
    }

    // Read fraction part if any.
    // https://graphql.github.io/graphql-spec/draft/#FractionalPart
    if (_peek() == 0x2e /* . */) {
      isFloat = true;

      buffer.writeCharCode(_peek());
      _next();

      if (!isDigit(_peek())) {
        if (_isEOF) {
          throw _createSyntaxException(
              'Unexpected end of the file', Spanning.zeroWidth(_position));
        }

        final start = _position;
        final code = _peek();

        _next();

        throw _createSyntaxException(getUnexpectedCharExceptionMessage(code),
            Spanning(start, _position));
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
        if (_isEOF) {
          throw _createSyntaxException(
              'Unexpected end of the file', Spanning.zeroWidth(_position));
        }

        final start = _position;

        _next();

        throw _createSyntaxException(getUnexpectedCharExceptionMessage(_peek()),
            Spanning(start, _position));
      }
    }

    final code = _peek();

    if (code == 0x2e /* . */ || code == 0x45 /* E */ || code == 0x65 /* e */) {
      throw _createSyntaxException(
          getUnexpectedCharExceptionMessage(code), Spanning(start, _position));
    }

    return Token(
      isFloat ? TokenKind.floatValue : TokenKind.integerValue,
      Spanning(start, _position),
      value: buffer.toString(),
    );
  }

  int _scanEscapedUnicode() {
    final buffer = StringBuffer();
    final start = _position;
    int code;

    for (int _ = 0; _ < 4; _++) {
      _next();

      code = _peek();

      if (isDigit(code) ||
          (isLetter(code) && (code <= 0x46 /* F */ || code <= 0x66 /* f */))) {
        buffer.writeCharCode(code);
        continue;
      }

      _next();

      throw _createSyntaxException(
          'Unknown unicode escape sequence: "\\u${buffer.toString()}"',
          Spanning(start, _position));
    }

    code = int.tryParse(buffer.toString(), radix: 16);

    if (code != null) {
      return String.fromCharCode(code).codeUnitAt(0);
    }

    _next();

    throw _createSyntaxException(
        'Unknown unicode escape sequence: "\\u${buffer.toString()}"',
        Spanning(start, _position));
  }

  /// https://facebook.github.io/graphql/draft/#sec-String-Value
  Token _scanString() {
    final start = _position;
    final buffer = StringBuffer();
    int code;

    // skip leading quote.
    _next();

    while (!_isEOF) {
      code = _peek();

      if (!isValidSourceChar(code)) {
        throw _createSyntaxException(getUnexpectedCharExceptionMessage(code),
            Spanning(start, _position));
      }

      if (code == 0x22 /* " */) {
        _next();

        return Token(TokenKind.stringValue, Spanning(start, _position),
            value: buffer.toString());
      } else if (code == 0x5c /* \ */) {
        // skip `\`.
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
            _next();

            throw _createSyntaxException(
                'Unknown escape sequence: "\\${String.fromCharCode(code)}"',
                Spanning(start, _position));
        }
      } else if (code == 0x0a /* \n */ || code == 0x0d /* \r */) {
        throw _createSyntaxException(
            'Unterminated string!', Spanning(start, _position));
      } else {
        buffer.writeCharCode(code);
      }

      _next();
    }

    throw _createSyntaxException(
        'Unterminated string!', Spanning(start, _position));
  }

  Token _scanBlockString() {
    final start = _position;
    final buffer = StringBuffer();
    int code;

    // skipping leading `"""`
    _next();
    _next();
    _next();

    while (!_isEOF) {
      code = _peek();

      if (!isValidSourceChar(code)) {
        final start = _position;

        _next();

        throw _createSyntaxException(getUnexpectedCharExceptionMessage(code),
            Spanning(start, _position));
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

        final value = formatBlockStringValue(buffer.toString());

        return Token(TokenKind.blockStringValue, Spanning(start, _position),
            value: value);
      } else if (_scanEol()) {
        buffer.writeCharCode(0x0a /* \n */);
      } else {
        buffer.writeCharCode(code);
      }

      _next();
    }

    throw _createSyntaxException(
        'Unterminated string!', Spanning(start, _position));
  }

  /// Consumes identifier or a keyword such as operations, fields, etc.
  /// `[_A-Za-z][_0-9A-Za-z]*`.
  ///
  /// https://facebook.github.io/graphql/draft/#sec-Names
  Token _scanIdent() {
    final buffer = StringBuffer();
    final start = _position;
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
      final kind = TokenKind.maybeKeywordOrIdentifier(value);

      return Token(
        kind,
        Spanning(start, _position),
        value: kind == TokenKind.ident ? value : null,
      );
    }

    throw _createSyntaxException(
        getUnexpectedCharExceptionMessage(code), Spanning(start, _position));
  }

  Token _scanToken() {
    _skipWhitespace();

    final code = _peek();

    if (code == -1 /* EOF */) {
      return Token(TokenKind.eof, Spanning.zeroWidth(_position));
    } else if (code < 0x20 && code != 0x09 && code != 0x0a && code != 0x0d) {
      final start = _position;

      _next();

      throw _createSyntaxException(
          getUnexpectedCharExceptionMessage(code), Spanning(start, _position));
    } else if (code == 0x23 /* # */) {
      return _scanComment();
    } else if (_punctuators.containsKey(code)) {
      final kind = _punctuators[code];
      final start = _position;

      _next();

      return Token(kind, Spanning(start, _position));
    } else if (code == 0x2d /* - */ || isDigit(code)) {
      return _scanNumber();
    } else if (isLetter(code) || code == 0x5f /* _ */) {
      return _scanIdent();
    } else if (code == 0x2e /* . */) {
      if (_peek(1) == 0x2e && _peek(2) == 0x2e) {
        final start = _position;

        _next();
        _next();
        _next();

        return Token(TokenKind.spread, Spanning(start, _position));
      }
    } else if (code == 0x22 /* " */) {
      if (_peek(1) == 0x22 && _peek(2) == 0x22) {
        return _scanBlockString();
      }

      return _scanString();
    }

    throw _createSyntaxException(
        getUnexpectedCharExceptionMessage(code), Spanning.zeroWidth(_position));
  }

  Iterable<Token> lex() sync* {
    Token token;

    do {
      token = _scanToken();

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
