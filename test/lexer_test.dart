// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'dart:convert' show utf8;

import 'package:test/test.dart';

import 'package:graphite_language/lexer.dart';
import 'package:graphite_language/token.dart';

import 'package:graphite_language/errors.dart' show SyntaxError;

Iterable<Token> lex(String body) {
  final lexer = Lexer(Source(body: body));

  return lexer.lex();
}

Token lexOne(String body) => lex(body).first;

void expectPosition(Position current, Position expected) {
  expect(current.offset, expected.offset);
  expect(current.line, expected.line);
  expect(current.column, expected.column);
}

void expectSpanning(Spanning current, Spanning expected) {
  expectPosition(current.start, expected.start);
  expectPosition(current.end, expected.end);
}

void expectToken(Token current, Token expected, {bool skip = false}) {
  if (skip) {
    return;
  }

  expect(current.kind, expected.kind);
  expect(current.value, expected.value);
  expectSpanning(current.spanning, expected.spanning);
}

void main() {
  group('Punctuators', () {
    test('lexes punctuators', () {
      const expectedSpanning = Spanning(Position(offset: 0, line: 1, column: 1),
          Position(offset: 1, line: 1, column: 2));

      expectToken(lexOne('!'), const Token(TokenKind.bang, expectedSpanning));
      expectToken(
          lexOne('\$'), const Token(TokenKind.dollar, expectedSpanning));
      expectToken(lexOne('('), const Token(TokenKind.parenl, expectedSpanning));
      expectToken(lexOne(')'), const Token(TokenKind.parenr, expectedSpanning));
      expectToken(lexOne(':'), const Token(TokenKind.colon, expectedSpanning));
      expectToken(lexOne('='), const Token(TokenKind.eq, expectedSpanning));
      expectToken(lexOne('@'), const Token(TokenKind.at, expectedSpanning));
      expectToken(lexOne('['), const Token(TokenKind.bracel, expectedSpanning));
      expectToken(lexOne(']'), const Token(TokenKind.bracer, expectedSpanning));
      expectToken(
          lexOne('{'), const Token(TokenKind.bracketl, expectedSpanning));
      expectToken(lexOne('|'), const Token(TokenKind.pipe, expectedSpanning));
      expectToken(
          lexOne('}'), const Token(TokenKind.bracketr, expectedSpanning));
      expectToken(
          lexOne('...'),
          const Token(
              TokenKind.spread,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 3, line: 1, column: 4))));
    });
  });

  group('whitespace', () {
    test('accepts BOM header', () {
      expectToken(
          lexOne('\ufeff@'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 1, line: 1, column: 2),
                  Position(offset: 2, line: 1, column: 3))));
    });

    test('tracks line and column', () {
      expectToken(
          lexOne('\n\r\n\r@\n'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 4, line: 4, column: 1),
                  Position(offset: 5, line: 4, column: 2))));
    });

    test('skips whitespace and comments', () {
      expectToken(
          lexOne('\n \r \r\n # @    \n@\n\n'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 15, line: 5, column: 1),
                  Position(offset: 16, line: 5, column: 2))));

      expectToken(
          lexOne('# comment'),
          const Token(
              TokenKind.eof,
              Spanning(Position(offset: 9, line: 1, column: 10),
                  Position(offset: 9, line: 1, column: 10))));
    });

    test('skips insignificant comma', () {
      expectToken(
          lexOne(',,,,@,,,,'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 4, line: 1, column: 5),
                  Position(offset: 5, line: 1, column: 6))));
    });
  });

  test('lexes numbers', () {
    expectToken(
        lexOne('0'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 1, line: 1, column: 2)),
            value: '0'));

    expectToken(
        lexOne('52321'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '52321'));

    expectToken(
        lexOne('-52'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 3, line: 1, column: 4)),
            value: '-52'));

    expectToken(
        lexOne('-123123'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 7, line: 1, column: 8)),
            value: '-123123'));

    expectToken(
        lexOne('-52e6'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '-52e6'));

    expectToken(
        lexOne('3.14'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 4, line: 1, column: 5)),
            value: '3.14'));

    expectToken(
        lexOne('-52.234'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 7, line: 1, column: 8)),
            value: '-52.234'));

    expectToken(
        lexOne('5.1222e6'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 8, line: 1, column: 9)),
            value: '5.1222e6'));

    expectToken(
        lexOne('5.1e+2'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 6, line: 1, column: 7)),
            value: '5.1e+2'));

    expectToken(
        lexOne('-5.1e+245'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 9, line: 1, column: 10)),
            value: '-5.1e+245'));

    expectToken(
        lexOne('-5e-2'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '-5e-2'));

    expectToken(
        lexOne('\n,\n    \n-1042345.000e+21 \r, ,,,  '),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 8, line: 4, column: 1),
                Position(offset: 24, line: 4, column: 17)),
            value: '-1042345.000e+21'));

    expect(() => lexOne('00'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('0123123'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('1..00'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('2e'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('2e++32'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('2.'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('.1'), throwsA(const TypeMatcher<SyntaxError>()));
    expect(() => lexOne('1.F'), throwsA(const TypeMatcher<SyntaxError>()));
  });

  group('String', () {
    test('lexes string', () {
      expectToken(
          lexOne('""'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 2, line: 1, column: 3)),
              value: ''));

      expectToken(
          lexOne('"hello world"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 13, line: 1, column: 14)),
              value: 'hello world'));

      expectToken(
          lexOne('" with space "'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 14, line: 1, column: 15)),
              value: ' with space '));

      expectToken(
          lexOne('"with quote \\""'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 15, line: 1, column: 16)),
              value: 'with quote "'));

      expectToken(
          lexOne('"\\\\"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\\'));

      expectToken(
          lexOne('"\\b"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\b'));

      expectToken(
          lexOne('"\\f"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\f'));

      expectToken(
          lexOne('"\\r"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\r'));

      expectToken(
          lexOne('"\\t"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\t'));

      expectToken(
          lexOne('"combined escape \\" \\\\\\\\/\\b\\f\\n\\r\\t"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 36, line: 1, column: 37)),
              value: 'combined escape " \\\\/\b\f\n\r\t'));

      expectToken(
          lexOne('"with unicode \\u1234\\u5678\\u90aB\\uCdEf"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 39, line: 1, column: 40)),
              value: 'with unicode ሴ噸邫췯'));

      // SKIPPED!
      expectToken(
          lexOne('"\\ude40"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 7, line: 1, column: 8)),
              value: '🙀'),
          skip: true);

      expect(() => lexOne('"\\x"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"\\z"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"\\u"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(
          () => lexOne('"\\uXXXX"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"\\u1"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(
          () => lexOne('"\\u12"'), throwsA(const TypeMatcher<SyntaxError>()));
      expect(
          () => lexOne('"\\u123"'), throwsA(const TypeMatcher<SyntaxError>()));

      expect(() => lexOne('"unterminated string'),
          throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"unterminated string\n"'),
          throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"unterminated string\r"'),
          throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"unterminated string\r\n"'),
          throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"unterminated string\r\n"'),
          throwsA(const TypeMatcher<SyntaxError>()));
    });
  });

  group('BlockString', () {
    test('throws on invalid source characters', () {
      // Only valid source characters: /[\u0009\u000A\u000D\u0020-\uFFFF]/
      // https://graphql.github.io/graphql-spec/draft/#SourceCharacter

      expect(() => lexOne('"""${utf8.decode([0x19, 0x18])}"""'),
          throwsA(const TypeMatcher<SyntaxError>()));
      expect(() => lexOne('"""${utf8.decode([0x09])}"""'), returnsNormally);
    });

    test('lexes empty string', () {
      expectToken(
          lexOne('""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7)),
              value: ''));
    });

    test('skips escaped triple-quotes', () {
      expectToken(
          lexOne('"""\\""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 10, line: 1, column: 11)),
              value: '"""'));

      expectToken(
          lexOne('"""\\"""\\"""asd\\""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 21, line: 1, column: 22)),
              value: '""""""asd"""'));
    });

    test('correctly lexes slashes', () {
      expectToken(
          lexOne('"""\\\\\\\\\\\\/\\b\\b"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 17, line: 1, column: 18)),
              value: '\\\\\\\\\\\\/\\b\\b'));
    });

    test('correctly handles newlines', () {
      expectToken(
          lexOne('"""\r\n\n\rblock string\r"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 23, line: 5, column: 4)),
              value: 'block string'));

      expectToken(
          lexOne('"""block\r""\\"string"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 22, line: 2, column: 14)),
              value: 'block\n""\\"string'));

      expectToken(
          lexOne('''"""
          
          
          
          """'''),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 50, line: 5, column: 14)),
              value: ''));

      expectToken(
          lexOne('''"""

            multi
              line
                block-string
                """'''),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 90, line: 6, column: 20)),
              value: 'multi\n  line\n    block-string'));
    });

    test('does not accidentally eat other tokens', () {
      expectToken(
          lex('"""\n\r\nfloat check\n       \n"""3213.41e23').elementAt(1),
          const Token(
              TokenKind.floatValue,
              Spanning(Position(offset: 29, line: 5, column: 4),
                  Position(offset: 39, line: 5, column: 14)),
              value: '3213.41e23'));

      expectToken(
          lexOne('"""at"""@'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9)),
              value: 'at'));
    });
  });

  group('Keywords', () {
    test('lexes correctly', () {
      expectToken(
          lexOne('enum'),
          const Token(
              TokenKind.enumKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expectToken(
          lexOne('extend'),
          const Token(
              TokenKind.extendKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expectToken(
          lexOne('fragment'),
          const Token(
              TokenKind.fragmentKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9))));

      expectToken(
          lexOne('implements'),
          const Token(
              TokenKind.implementsKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 10, line: 1, column: 11))));

      expectToken(
          lexOne('input'),
          const Token(
              TokenKind.inputKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));

      expectToken(
          lexOne('interface'),
          const Token(
              TokenKind.interfaceKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 9, line: 1, column: 10))));

      expectToken(
          lexOne('mutation'),
          const Token(
              TokenKind.mutationKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9))));

      expectToken(
          lexOne('null'),
          const Token(
              TokenKind.nullKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expectToken(
          lexOne('on'),
          const Token(
              TokenKind.onKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 2, line: 1, column: 3))));

      expectToken(
          lexOne('query'),
          const Token(
              TokenKind.queryKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));

      expectToken(
          lexOne('scalar'),
          const Token(
              TokenKind.scalarKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expectToken(
          lexOne('schema'),
          const Token(
              TokenKind.schemaKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expectToken(
          lexOne('subscription'),
          const Token(
              TokenKind.subscriptionKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 12, line: 1, column: 13))));

      expectToken(
          lexOne('type'),
          const Token(
              TokenKind.typeKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expectToken(
          lexOne('union'),
          const Token(
              TokenKind.unionKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));
    });
  });

  group('Identifiers', () {
    test('lexes correctly', () {
      expectToken(
          lexOne('\r\n,,identifier,,,\n@f\n'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 4, line: 2, column: 3),
                  Position(offset: 14, line: 2, column: 13)),
              value: 'identifier'));

      expectToken(
          lexOne('long_long_long_identifierNamedUsingDifferentStyles'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 50, line: 1, column: 51)),
              value: 'long_long_long_identifierNamedUsingDifferentStyles'));

      expectToken(
          lex('"hello world" @foo').elementAt(2),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 15, line: 1, column: 16),
                  Position(offset: 18, line: 1, column: 19)),
              value: 'foo'));

      expectToken(
          lexOne('test_123_in_ident567'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 20, line: 1, column: 21)),
              value: 'test_123_in_ident567'));

      expectToken(
          lex('123.123 foo bar').elementAt(2),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 12, line: 1, column: 13),
                  Position(offset: 15, line: 1, column: 16)),
              value: 'bar'));
    });
  });
}
