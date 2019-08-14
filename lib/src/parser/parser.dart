// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

import 'package:graphite_language/ast.dart' as ast;
import 'package:graphite_language/lexer.dart' show Lexer;
import 'package:graphite_language/token.dart'
    show Source, Token, TokenKind, Keyword;

class Parser {
  Parser(this.source);

  factory Parser.fromString(String code) => Parser(Source(body: code));

  final Source source;

  List<Token> _tokens;
  int _index;

  Token _lookahead(int offset) => _tokens[_index + offset];

  Token _peek() => _lookahead(0);

  bool _isKindOf(TokenKind kind) => _peek().kind == kind;

  void _expectToken(TokenKind kind) {
    if (!_isKindOf(kind)) {
      throw Exception(
          'Unexpected token, expected token of kind $kind, received ${_peek().kind}');
    }
  }

  void _expectKeywordToken(String keyword) {
    _expectToken(TokenKind.name);

    if (_peek().value != keyword) {
      throw Exception(
          'Unexpected token name, expected keyword $keyword, found ${_peek().value}');
    }
  }

  Token _advanceToken() => _tokens[_index++];

  void _eatToken() => _advanceToken();

  bool _isOptionalKindOf(TokenKind kind) {
    if (_isKindOf(kind)) {
      _eatToken();

      return true;
    }

    return false;
  }

  Iterable<T> _many<T extends ast.Node>(
      TokenKind beginToken, T consume(), TokenKind endToken) {
    _expectToken(beginToken);
    _eatToken();

    final nodes = <T>[];

    do {
      nodes.add(consume());
    } while (!_isKindOf(endToken));

    _eatToken();

    return nodes;
  }

  bool get _isEOF => _peek().kind == TokenKind.eof;

  /// Completely parses the source code provided by [source] and returns
  /// [ast.Document] representing the source.
  ///
  /// Given [ast.Document] is root of the whole AST tree as such it can be
  /// traversed by using [ast.Visitor].
  ast.Document parse() {
    final lexer = Lexer(source);
    _tokens = lexer.lex().toList();
    _index = 0;

    return _parseDocument();
  }

  String _parseName() {
    _expectToken(TokenKind.name);

    return _advanceToken().value;
  }

  ast.Document _parseDocument() {
    final definitions = <ast.Node>[];

    while (!_isEOF) {
      definitions.add(_parseDefinition());
    }

    return ast.Document(
      definitions: definitions,
    );
  }

  ast.Node _parseDefinition() {
    final tok = _peek();

    if (tok.kind == TokenKind.name) {
      switch (tok.value) {
        // https://graphql.github.io/graphql-spec/draft/#ExecutableDefinition
        // ------------------------------------------------------------------
        case Keyword.query:
        case Keyword.mutation:
        case Keyword.subscription:
          return _parseOperationDefinition();

        case Keyword.fragment:
          return _parseFragmentDefinition();

        // https://graphql.github.io/graphql-spec/draft/#TypeSystemDefinition
        // ------------------------------------------------------------------

        case Keyword.schema:
          return _parseSchemaDefinition();

        case Keyword.scalar:
        case Keyword.type:
        case Keyword.interface:
        case Keyword.union:
        case Keyword.kEnum:
        case Keyword.input:
          return _parseTypeDefinition();

        case Keyword.extend:
          return _parseTypeExtension();
      }
    } else if (tok.kind == TokenKind.bracketl) {
      return _parseSelectionSet();
    } else if (tok.kind == TokenKind.stringValue ||
        tok.kind == TokenKind.blockStringValue) {
      return _parseTypeDefinition();
    }

    throw Exception('Unexpected token!');
  }

  ast.SchemaDefinition _parseSchemaDefinition() {
    _expectKeywordToken(Keyword.schema);
    _eatToken();

    final definitions = <ast.RootOperationTypeDefinition>[];
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;

    _expectToken(TokenKind.bracketl);
    _eatToken();

    do {
      definitions.add(_parseRootOperationTypeDefinition());
    } while (_peek().kind != TokenKind.bracketr);

    _eatToken();

    return ast.SchemaDefinition(
        definitions: definitions, directives: directives);
  }

  ast.RootOperationTypeDefinition _parseRootOperationTypeDefinition() {
    final operation = _parseOperationType();

    _expectToken(TokenKind.colon);
    _eatToken();

    return ast.RootOperationTypeDefinition(
        operation: operation, value: _parseNamedType());
  }

  ast.OperationType _parseOperationType() =>
      ast.OperationType.fromString(_parseName());

  ast.OperationDefinition _parseOperationDefinition() =>
      ast.OperationDefinition(
        operationType: _parseOperationType(),
        name: _isKindOf(TokenKind.name) ? _parseName() : null,
        variableDefinitions:
            _isKindOf(TokenKind.parenl) ? _parseVariableDefinitions() : null,
        directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
        selectionSet: _parseSelectionSet(),
      );

  Iterable<ast.VariableDefinition> _parseVariableDefinitions() {
    _expectToken(TokenKind.parenl);
    _eatToken();

    final variableDefinitions = <ast.VariableDefinition>[];

    do {
      variableDefinitions.add(_parseVariableDefinition());
    } while (!_isKindOf(TokenKind.parenr));

    _expectToken(TokenKind.parenr);
    _eatToken();

    return variableDefinitions;
  }

  ast.VariableDefinition _parseVariableDefinition() {
    final variable = _parseVariable();

    _expectToken(TokenKind.colon);
    _eatToken();

    final type = _parseType();

    ast.Node defaultValue;
    if (_isKindOf(TokenKind.eq)) {
      _eatToken(); // eat `eq` token
      defaultValue = _parseValue();
    }

    return ast.VariableDefinition(
      variable: variable,
      type: type,
      defaultValue: defaultValue,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  ast.Node _parseType() {
    ast.Node type;

    switch (_peek().kind) {
      case TokenKind.name:
        type = _parseNamedType();
        break;

      case TokenKind.bracel:
        type = _parseListType();
        break;

      default:
        throw Exception('Unexpected token!');
    }

    if (_peek().kind == TokenKind.bang) {
      type = ast.NonNullType(type: type);
      _eatToken();
    }

    return type;
  }

  ast.NamedType _parseNamedType() {
    _expectToken(TokenKind.name);

    return ast.NamedType(name: _parseName());
  }

  ast.ListType _parseListType() {
    _expectToken(TokenKind.bracel);
    _eatToken();

    final type = ast.ListType(type: _parseType());

    _expectToken(TokenKind.bracer);
    _eatToken();

    return type;
  }

  ast.FragmentDefinition _parseFragmentDefinition() {
    _expectToken(TokenKind.name);

    if (_peek().value != Keyword.fragment) {
      throw Exception('Unexpected token name!');
    }

    return ast.FragmentDefinition(
      name: _parseName(),
      typeCondition: _parseTypeCondition(),
      selectionSet: _parseSelectionSet(),
    );
  }

  ast.SelectionSet _parseSelectionSet() => ast.SelectionSet(
      selections:
          _many(TokenKind.bracketl, _parseSelection, TokenKind.bracketr));

  ast.Node _parseSelection() {
    switch (_peek().kind) {
      case TokenKind.spread:
        final next = _lookahead(1);
        if (next.kind == TokenKind.name && next.value != Keyword.on) {
          return _parseFragmentSpread();
        } else {
          return _parseInlineFragment();
        }
        break;

      case TokenKind.name:
        return _parseField();
        break;

      default:
        throw Exception(
            'Expected ${TokenKind.name} or ${TokenKind.spread} token, was ${_peek().kind}!');
    }
  }

  ast.InlineFragment _parseInlineFragment() {
    _expectToken(TokenKind.spread);
    _eatToken();

    final token = _peek();
    ast.TypeCondition typeCondition;

    if (token.kind == TokenKind.name && token.value == Keyword.on) {
      typeCondition = _parseTypeCondition();
    }

    return ast.InlineFragment(
      typeCondition: typeCondition,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
      selectionSet: _parseSelectionSet(),
    );
  }

  ast.TypeCondition _parseTypeCondition() {
    _expectKeywordToken(Keyword.on);
    _eatToken();

    return ast.TypeCondition(name: _parseName());
  }

  ast.FragmentSpread _parseFragmentSpread() {
    _expectToken(TokenKind.spread);

    final token = _advanceToken();

    if (token.kind == TokenKind.name && token.value == Keyword.on) {
      throw Exception('Unexpected token name!');
    }

    return ast.FragmentSpread(
      name: _parseName(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  ast.Field _parseField() => ast.Field(
        alias: _lookahead(1).kind == TokenKind.colon ? _parseAlias() : null,
        name: _parseName(),
        arguments: _isKindOf(TokenKind.parenl) ? _parseArguments() : null,
        directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
        selectionSet:
            _isKindOf(TokenKind.bracketl) ? _parseSelectionSet() : null,
      );

  ast.Alias _parseAlias() {
    _expectToken(TokenKind.name);

    final name = _parseName();

    _expectToken(TokenKind.colon);

    return ast.Alias(name: name);
  }

  Iterable<ast.Argument> _parseArguments() {
    _expectToken(TokenKind.parenl);
    _eatToken();

    final arguments = <ast.Argument>[];

    do {
      arguments.add(_parseArgument());
    } while (!_isKindOf(TokenKind.parenr));

    _expectToken(TokenKind.parenr);
    _eatToken();

    return arguments;
  }

  ast.Argument _parseArgument() {
    final name = _parseName();

    _expectToken(TokenKind.colon);
    _advanceToken();

    return ast.Argument(name: name, value: _parseValue());
  }

  ast.Node _parseValue({bool isConst = true}) {
    final token = _peek();

    switch (token.kind) {
      case TokenKind.dollar:
        return _parseVariable();

      case TokenKind.integerValue:
        return ast.IntValue(int.parse(_advanceToken().value));

      case TokenKind.floatValue:
        return ast.FloatValue(double.parse(_advanceToken().value));

      case TokenKind.stringValue:
        return ast.StringValue(_advanceToken().value);

      case TokenKind.name:
        if (token.value == Keyword.kNull) {
          return const ast.NullValue(null);
        } else if (token.value == Keyword.kTrue ||
            token.value == Keyword.kFalse) {
          return ast.BooleanValue(_advanceToken().value == Keyword.kTrue);
        }

        return _parseEnumValue();

      case TokenKind.bracel:
        _eatToken();

        final values = <ast.Node>[];

        do {
          values.add(_parseValue(isConst: isConst));
        } while (_isKindOf(TokenKind.bracer));

        _eatToken();

        return ast.ListValue(values);

      case TokenKind.bracketl:
        _eatToken();

        final fields = <ast.ObjectField>[];

        do {
          fields.add(ast.ObjectField(
            name: _parseName(),
            value: _parseValue(isConst: isConst),
          ));
        } while (_isKindOf(TokenKind.bracketr));

        _eatToken();

        return ast.ObjectValue(fields);
    }

    throw Exception('Unexpected token!');
  }

  ast.EnumValue _parseEnumValue() {
    _expectToken(TokenKind.name);

    final name = _peek().value;

    switch (name) {
      case Keyword.kNull:
      case Keyword.kTrue:
      case Keyword.kFalse:
        throw Exception('Unexpected token!');

      default:
        return ast.EnumValue(_advanceToken().value);
    }
  }

  ast.Variable _parseVariable() {
    _expectToken(TokenKind.dollar);
    _eatToken();

    return ast.Variable(name: _parseName());
  }

  Iterable<ast.Directive> _parseDirectives() {
    final directives = <ast.Directive>[];

    do {
      directives.add(_parseDirective());
    } while (_isKindOf(TokenKind.at));

    return directives;
  }

  ast.Directive _parseDirective() {
    _expectToken(TokenKind.at);
    _eatToken();

    return ast.Directive(
      name: _parseName(),
      arguments: _isKindOf(TokenKind.bracel) ? _parseArguments() : null,
    );
  }

  ast.Node _parseTypeDefinition() {
    final hasDescription = _isKindOf(TokenKind.stringValue) ||
        _isKindOf(TokenKind.blockStringValue);
    final tok = hasDescription ? _lookahead(1) : _peek();

    switch (tok.value) {
      case Keyword.scalar:
        return _parseScalarTypeDefinition();
        break;
      case Keyword.type:
        return _parseObjectTypeDefinition();
        break;
      case Keyword.interface:
        return _parseInterfaceTypeDefinition();
        break;
      case Keyword.union:
        return _parseUnionTypeDefinition();
        break;
      case Keyword.kEnum:
        return _parseEnumTypeDefinition();
        break;
      case Keyword.input:
        return _parseInputTypeDefinition();
        break;
    }

    throw Exception('Unexpected keyword!');
  }

  ast.Node _parseScalarTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.scalar);
    _eatToken();

    return ast.ScalarTypeDefinition(
      name: _parseName(),
      description: description,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  ast.Node _parseObjectTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.type);
    _eatToken();

    final name = _parseName();
    List<ast.NamedType> interfaces;

    if (_isKindOf(TokenKind.name) && _peek().value == Keyword.implements) {
      _eatToken();
      interfaces = [];

      // Optional leading ampersand. WTF spec?
      if (_peek().kind == TokenKind.amp) {
        _eatToken();
      }

      do {
        interfaces.add(_parseNamedType());
      } while (_isOptionalKindOf(TokenKind.amp));
    }

    return ast.ObjectTypeDefinition(
      name: name,
      description: description,
      interfaces: interfaces,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
      fields: _isKindOf(TokenKind.bracketl) ? _parseFieldsDefinition() : null,
    );
  }

  Iterable<ast.FieldDefinition> _parseFieldsDefinition() =>
      _many(TokenKind.bracketl, _parseFieldDefinition, TokenKind.bracketr);

  ast.FieldDefinition _parseFieldDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;
    final name = _parseName();
    final arguments =
        _isKindOf(TokenKind.parenl) ? _parseArgumentsDefinition() : null;

    _expectToken(TokenKind.colon);
    _eatToken();

    return ast.FieldDefinition(
      description: description,
      name: name,
      arguments: arguments,
      type: _parseType(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  Iterable<ast.InputValueDefinition> _parseArgumentsDefinition() =>
      _many(TokenKind.parenl, _parseArgumentDefinition, TokenKind.parenr);

  ast.InputValueDefinition _parseArgumentDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;
    final name = _parseName();

    _expectToken(TokenKind.colon);
    _eatToken();

    return ast.InputValueDefinition(
      description: description,
      name: name,
      type: _parseType(),
      defaultValue:
          _isOptionalKindOf(TokenKind.eq) ? _parseValue(isConst: true) : null,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  ast.Node _parseInterfaceTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.interface);
    _eatToken();

    return ast.InterfaceTypeDefinition(
      description: description,
      name: _parseName(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
      fields: _isKindOf(TokenKind.bracketl) ? _parseFieldsDefinition() : null,
    );
  }

  ast.Node _parseUnionTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.union);

    return ast.UnionTypeDefinition();
  }

  ast.Node _parseEnumTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.kEnum);
    _eatToken();

    return ast.EnumTypeDefinition(
      description: description,
      name: _parseName(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
      values:
          _isKindOf(TokenKind.bracketl) ? _parseEnumValuesDefinition() : null,
    );
  }

  Iterable<ast.EnumValueDefinition> _parseEnumValuesDefinition() =>
      _many(TokenKind.bracketl, _parseEnumValueDefinition, TokenKind.bracketr);

  ast.EnumValueDefinition _parseEnumValueDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    return ast.EnumValueDefinition(
      description: description,
      value: _parseEnumValue(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  ast.Node _parseInputTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectKeywordToken(Keyword.input);

    return ast.InputObjectTypeDefinition();
  }

  String _parseDescription() {
    if (!_isKindOf(TokenKind.stringValue) &&
        !_isKindOf(TokenKind.blockStringValue)) {
      throw Exception('Unexpected token!');
    }

    return _advanceToken().value;
  }

  ast.Node _parseTypeExtension() {
    switch (_lookahead(1).value) {
      case Keyword.scalar:
        return _parseScalarTypeExtension();

      case Keyword.interface:
        return _parseInterfaceTypeExtension();

      case Keyword.kEnum:
        return _parseEnumTypeExtension();

      case Keyword.type:
      case Keyword.union:
      case Keyword.input:
        break;
    }
  }

  ast.ScalarTypeExtension _parseScalarTypeExtension() {
    _expectKeywordToken(Keyword.extend);
    _eatToken();
    _expectKeywordToken(Keyword.scalar);
    _eatToken();

    return ast.ScalarTypeExtension(
      name: _parseName(),
      directives: _parseDirectives(),
    );
  }

  ast.InterfaceTypeExtension _parseInterfaceTypeExtension() {
    _expectKeywordToken(Keyword.extend);
    _eatToken();
    _expectKeywordToken(Keyword.interface);
    _eatToken();

    final name = _parseName();
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    final fields =
        _isKindOf(TokenKind.bracketl) ? _parseFieldsDefinition() : null;

    if (directives == null && fields == null) {
      throw Exception('Expected either directives or field definitions!');
    }

    return ast.InterfaceTypeExtension(
      name: name,
      directives: directives,
      fields: fields,
    );
  }

  ast.EnumTypeExtension _parseEnumTypeExtension() {
    _expectKeywordToken(Keyword.extend);
    _eatToken();
    _expectKeywordToken(Keyword.kEnum);
    _eatToken();

    final name = _parseName();
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    final values =
        _isKindOf(TokenKind.bracketl) ? _parseEnumValuesDefinition() : null;

    if (directives == null && values == null) {
      throw Exception('Expected either directives or field definitions!');
    }

    return ast.EnumTypeExtension(
      name: name,
      values: values,
      directives: directives
    );
  }
}

ast.Document parse(Source source) => Parser(source).parse();
