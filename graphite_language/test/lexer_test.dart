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

import 'package:graphite_language/exceptions.dart' show SyntaxException;

Iterable<Token> lex(String body,
    // ignore: avoid_positional_boolean_parameters
    [bool shouldHighlightSourceInExceptions = false]) {
  final lexer = Lexer(Source(body: body),
      shouldHighlightSourceInExceptions: shouldHighlightSourceInExceptions);

  return lexer.lex();
}

// ignore: avoid_positional_boolean_parameters
Token lexOne(String body, [bool shouldHighlightSourceInExceptions = false]) =>
    lex(body, shouldHighlightSourceInExceptions).first;

void main() {
  group('Punctuators', () {
    test('lexes punctuators', () {
      const expectedSpanning = Spanning(Position(offset: 0, line: 1, column: 1),
          Position(offset: 1, line: 1, column: 2));

      expect(lexOne('!'), const Token(TokenKind.bang, expectedSpanning));
      expect(lexOne('\$'), const Token(TokenKind.dollar, expectedSpanning));
      expect(lexOne('('), const Token(TokenKind.parenl, expectedSpanning));
      expect(lexOne(')'), const Token(TokenKind.parenr, expectedSpanning));
      expect(lexOne(':'), const Token(TokenKind.colon, expectedSpanning));
      expect(lexOne('='), const Token(TokenKind.eq, expectedSpanning));
      expect(lexOne('@'), const Token(TokenKind.at, expectedSpanning));
      expect(lexOne('['), const Token(TokenKind.bracel, expectedSpanning));
      expect(lexOne(']'), const Token(TokenKind.bracer, expectedSpanning));
      expect(lexOne('{'), const Token(TokenKind.bracketl, expectedSpanning));
      expect(lexOne('|'), const Token(TokenKind.pipe, expectedSpanning));
      expect(lexOne('}'), const Token(TokenKind.bracketr, expectedSpanning));
      expect(
          lexOne('...'),
          const Token(
              TokenKind.spread,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 3, line: 1, column: 4))));
      expect(
          lex('{...}').elementAt(2),
          const Token(
              TokenKind.bracketr,
              Spanning(Position(offset: 4, line: 1, column: 5),
                  Position(offset: 5, line: 1, column: 6))));
    });
  });

  group('whitespace', () {
    test('accepts BOM header', () {
      expect(
          lexOne('\ufeff@'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 1, line: 1, column: 2),
                  Position(offset: 2, line: 1, column: 3))));
    });

    test('tracks line and column', () {
      expect(
          lexOne('\n\r\n\r@\n'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 4, line: 4, column: 1),
                  Position(offset: 5, line: 4, column: 2))));
    });

    test('skips whitespace and comments', () {
      expect(
          lexOne('\n \r \r\n # @    \n@\n\n'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 15, line: 5, column: 1),
                  Position(offset: 16, line: 5, column: 2))));

      expect(
          lexOne('# comment'),
          const Token(
              TokenKind.eof,
              Spanning(Position(offset: 9, line: 1, column: 10),
                  Position(offset: 9, line: 1, column: 10))));
    });

    test('skips insignificant comma', () {
      expect(
          lexOne(',,,,@,,,,'),
          const Token(
              TokenKind.at,
              Spanning(Position(offset: 4, line: 1, column: 5),
                  Position(offset: 5, line: 1, column: 6))));
    });
  });

  test('lexes numbers', () {
    expect(
        lexOne('0'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 1, line: 1, column: 2)),
            value: '0'));

    expect(() => lexOne('01'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('01.23'), throwsA(const TypeMatcher<SyntaxException>()));

    expect(
        lexOne('52321'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '52321'));

    expect(
        lexOne('-52'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 3, line: 1, column: 4)),
            value: '-52'));

    expect(
        lexOne('-123123'),
        const Token(
            TokenKind.integerValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 7, line: 1, column: 8)),
            value: '-123123'));

    expect(
        lexOne('-52e6'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '-52e6'));

    expect(
        lexOne('3.14'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 4, line: 1, column: 5)),
            value: '3.14'));

    expect(
        lexOne('-52.234'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 7, line: 1, column: 8)),
            value: '-52.234'));

    expect(
        lexOne('5.1222e6'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 8, line: 1, column: 9)),
            value: '5.1222e6'));

    expect(
        lexOne('5.1e+2'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 6, line: 1, column: 7)),
            value: '5.1e+2'));

    expect(
        lexOne('-5.1e+245'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 9, line: 1, column: 10)),
            value: '-5.1e+245'));

    expect(
        lexOne('-5e-2'),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 0, line: 1, column: 1),
                Position(offset: 5, line: 1, column: 6)),
            value: '-5e-2'));

    expect(
        lexOne('\n,\n    \n-1042345.000e+21 \r, ,,,  '),
        const Token(
            TokenKind.floatValue,
            Spanning(Position(offset: 8, line: 4, column: 1),
                Position(offset: 24, line: 4, column: 17)),
            value: '-1042345.000e+21'));

    expect(() => lexOne('00'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(
        () => lexOne('0123123'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(
        () => lexOne('1..00'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('2e'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(
        () => lexOne('2e++32'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('2.'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('.1'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('1.E'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('1.2e3e'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('1.2e3.4'), throwsA(const TypeMatcher<SyntaxException>()));
    expect(() => lexOne('1.23.4'), throwsA(const TypeMatcher<SyntaxException>()));
  });

  group('String', () {
    test('lexes string', () {
      expect(
          lexOne('""'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 2, line: 1, column: 3)),
              value: ''));

      expect(
          lexOne('"hello world"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 13, line: 1, column: 14)),
              value: 'hello world'));

      expect(
          lexOne('" with space "'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 14, line: 1, column: 15)),
              value: ' with space '));

      expect(
          () => lexOne('"""'), throwsA(const TypeMatcher<SyntaxException>()));
      expect(
          () => lexOne('""""'), throwsA(const TypeMatcher<SyntaxException>()));
    });

    test('lexes escape sequence', () {
      expect(
          lexOne('"with quote \\""'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 15, line: 1, column: 16)),
              value: 'with quote "'));

      expect(
          lexOne('"\\\\"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\\'));

      expect(
          lexOne('"\\b"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\b'));

      expect(
          lexOne('"\\f"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\f'));

      expect(
          lexOne('"\\r"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\r'));

      expect(
          lexOne('"\\t"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5)),
              value: '\t'));

      expect(
          lexOne('"combined escape \\" \\\\\\\\/\\b\\f\\n\\r\\t"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 36, line: 1, column: 37)),
              value: 'combined escape " \\\\/\b\f\n\r\t'));

      expect(
          lexOne('"with unicode \\u1234\\u5678\\u90aB\\uCdEf"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 39, line: 1, column: 40)),
              value: 'with unicode ሴ噸邫췯'));

      expect(
          lexOne('"\\ude40"'),
          const Token(
              TokenKind.stringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9)),
              value: '\ude40'));

      expect(
          () => lexOne('"\\x"'), throwsA(const TypeMatcher<SyntaxException>()));
      expect(
          () => lexOne('"\\z"'), throwsA(const TypeMatcher<SyntaxException>()));
      expect(
          () => lexOne('"\\u"'), throwsA(const TypeMatcher<SyntaxException>()));
      expect(() => lexOne('"\\uXXXX"'),
          throwsA(const TypeMatcher<SyntaxException>()));
      expect(() => lexOne('"\\u1"'),
          throwsA(const TypeMatcher<SyntaxException>()));
      expect(() => lexOne('"\\u12"'),
          throwsA(const TypeMatcher<SyntaxException>()));
      expect(() => lexOne('"\\u123"'),
          throwsA(const TypeMatcher<SyntaxException>()));

      expect(
          () => lex(
              'query {\n'
              '    user(username: "\\u123") {\n'
              '        firstName,\n'
              '        lastName\n'
              '    }\n'
              '}\n',
              true),
          throwsA(predicate<SyntaxException>((e) =>
              e.toString() ==
              'SyntaxException: Unknown unicode escape sequence: "\\u123"\n'
                  '1| query {\n'
                  '2|     user(username: "\\u123") {\n'
                  '                       ^^^^^\n'
                  '3|         firstName,\n\n')),
          skip: true);
    });

    test('throws on invalid source characters', () {
      expect(() => lexOne('"${utf8.decode([0x19, 0x18])}"'),
          throwsA(const TypeMatcher<SyntaxException>()));
    });

    test('throws on unterminated strings', () {
      expect(
          () => lexOne('"unterminated string'),
          throwsA(predicate<SyntaxException>(
              (e) => e.message == 'Unterminated string!')));

      expect(
          () => lexOne('"unterminated string\n"'),
          throwsA(predicate<SyntaxException>(
              (e) => e.message == 'Unterminated string!')));

      expect(() => lexOne('"unterminated string\r"'),
          throwsA(const TypeMatcher<SyntaxException>()));

      expect(() => lexOne('"unterminated string\r\n"'),
          throwsA(const TypeMatcher<SyntaxException>()));

      expect(() => lexOne('"unterminated string\r\n"'),
          throwsA(const TypeMatcher<SyntaxException>()));
    });
  });

  group('BlockString', () {
    test('throws on invalid source characters', () {
      // Only valid source characters: /[\u0009\u000A\u000D\u0020-\uFFFF]/
      // https://graphql.github.io/graphql-spec/draft/#SourceCharacter

      expect(
          () => lexOne('"""\u0019\u0018"""'),
          throwsA(predicate<SyntaxException>(
              (e) => e.message == 'Invalid source character: "\u0019"')));

      expect(() => lexOne('"""${utf8.decode([0x09])}"""'), returnsNormally);
    });

    test('lexes empty string', () {
      expect(
          lexOne('""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7)),
              value: ''));
    });

    test('skips escaped triple-quotes', () {
      expect(
          lexOne('"""\\""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 10, line: 1, column: 11)),
              value: '"""'));

      expect(
          lexOne('"""\\"""\\"""asd\\""""""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 21, line: 1, column: 22)),
              value: '""""""asd"""'));
    });

    test('correctly lexes slashes', () {
      expect(
          lexOne('"""\\\\\\\\\\\\/\\b\\b"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 17, line: 1, column: 18)),
              value: '\\\\\\\\\\\\/\\b\\b'));
    });

    test('correctly handles newlines', () {
      expect(
          lexOne('"""\r\n\n\rblock string\r"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 23, line: 5, column: 4)),
              value: 'block string'));

      expect(
          lexOne('"""block\r""\\"string"""'),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 22, line: 2, column: 14)),
              value: 'block\n""\\"string'));

      expect(
          lexOne('''"""
          
          
          
          """'''),
          const Token(
              TokenKind.blockStringValue,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 50, line: 5, column: 14)),
              value: ''));

      expect(
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
      expect(
          lex('"""\n\r\nfloat check\n       \n"""3213.41e23').elementAt(1),
          const Token(
              TokenKind.floatValue,
              Spanning(Position(offset: 29, line: 5, column: 4),
                  Position(offset: 39, line: 5, column: 14)),
              value: '3213.41e23'));

      expect(
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
      expect(
          lexOne('enum'),
          const Token(
              TokenKind.enumKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expect(
          lexOne('extend'),
          const Token(
              TokenKind.extendKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expect(
          lexOne('fragment'),
          const Token(
              TokenKind.fragmentKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9))));

      expect(
          lexOne('implements'),
          const Token(
              TokenKind.implementsKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 10, line: 1, column: 11))));

      expect(
          lexOne('input'),
          const Token(
              TokenKind.inputKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));

      expect(
          lexOne('interface'),
          const Token(
              TokenKind.interfaceKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 9, line: 1, column: 10))));

      expect(
          lexOne('mutation'),
          const Token(
              TokenKind.mutationKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 8, line: 1, column: 9))));

      expect(
          lexOne('null'),
          const Token(
              TokenKind.nullKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expect(
          lexOne('on'),
          const Token(
              TokenKind.onKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 2, line: 1, column: 3))));

      expect(
          lexOne('query'),
          const Token(
              TokenKind.queryKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));

      expect(
          lexOne('scalar'),
          const Token(
              TokenKind.scalarKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expect(
          lexOne('schema'),
          const Token(
              TokenKind.schemaKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 6, line: 1, column: 7))));

      expect(
          lexOne('subscription'),
          const Token(
              TokenKind.subscriptionKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 12, line: 1, column: 13))));

      expect(
          lexOne('type'),
          const Token(
              TokenKind.typeKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 4, line: 1, column: 5))));

      expect(
          lexOne('union'),
          const Token(
              TokenKind.unionKeyword,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 5, line: 1, column: 6))));
    });
  });

  group('Identifiers', () {
    test('lexes correctly', () {
      expect(
          lexOne('\r\n,,identifier,,,\n@f\n'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 4, line: 2, column: 3),
                  Position(offset: 14, line: 2, column: 13)),
              value: 'identifier'));

      expect(
          lexOne('long_long_long_identifierNamedUsingDifferentStyles'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 50, line: 1, column: 51)),
              value: 'long_long_long_identifierNamedUsingDifferentStyles'));

      expect(
          lex('"hello world" @foo').elementAt(2),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 15, line: 1, column: 16),
                  Position(offset: 18, line: 1, column: 19)),
              value: 'foo'));

      expect(
          lexOne('test_123_in_ident567'),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 0, line: 1, column: 1),
                  Position(offset: 20, line: 1, column: 21)),
              value: 'test_123_in_ident567'));

      expect(
          lex('123.123 foo bar').elementAt(2),
          const Token(
              TokenKind.ident,
              Spanning(Position(offset: 12, line: 1, column: 13),
                  Position(offset: 15, line: 1, column: 16)),
              value: 'bar'));
    });
  });
}
