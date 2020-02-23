import 'package:graphite_language/ast.dart' as ast;
import 'package:graphite_language/lexer.dart' show Lexer;
import 'package:graphite_language/token.dart' show Source, Token, TokenKind;

class Parser {
  Parser(this.source);

  factory Parser.fromString(String code) => Parser(Source(body: code));

  final Source source;

  List<Token> _tokens;
  int _index;

  Token _lookahead(int offset) => _tokens[_index + offset];

  Token _peek() => _lookahead(0);

  bool _isKindOf(TokenKind kind) => _peek().kind == kind;

  Token _expectToken(TokenKind kind) {
    if (!_isKindOf(kind)) {
      throw Exception(
          'Unexpected token, expected token of kind $kind, received ${_peek().kind}');
    }

    return _advanceToken();
  }

  Token _expectIdent() {
    final tok = _peek();

    if (!TokenKind.isIdentOrKeyword(tok.kind)) {
      throw Exception('Expected identifier found ${tok.kind}!');
    }

    return _advanceToken();
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

  String _parseName() => _expectIdent().value;

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
    final token = _peek();

    if (TokenKind.isKeyword(token.kind)) {
      switch (token.kind) {
        // https://graphql.github.io/graphql-spec/draft/#ExecutableDefinition
        // ------------------------------------------------------------------
        case TokenKind.queryKeyword:
        case TokenKind.mutationKeyword:
        case TokenKind.subscriptionKeyword:
          return _parseOperationDefinition();

        case TokenKind.fragmentKeyword:
          return _parseFragmentDefinition();

        // https://graphql.github.io/graphql-spec/draft/#TypeSystemDefinition
        // ------------------------------------------------------------------

        case TokenKind.schemaKeyword:
          return _parseSchemaDefinition();

        case TokenKind.scalarKeyword:
        case TokenKind.typeKeyword:
        case TokenKind.interfaceKeyword:
        case TokenKind.unionKeyword:
        case TokenKind.enumKeyword:
        case TokenKind.inputKeyword:
          return _parseTypeDefinition();

        case TokenKind.directiveKeyword:
          return _parseDirectiveDefinition();

        case TokenKind.extendKeyword:
          final nextToken = _lookahead(1);

          switch (nextToken.kind) {
            case TokenKind.schemaKeyword:
              return _parseSchemaExtension();

            case TokenKind.scalarKeyword:
            case TokenKind.typeKeyword:
            case TokenKind.interfaceKeyword:
            case TokenKind.unionKeyword:
            case TokenKind.enumKeyword:
            case TokenKind.inputKeyword:
              return _parseTypeExtension();
          }
      }
    } else if (token.kind == TokenKind.bracketl) {
      return _parseSelectionSet();
    } else if (token.kind == TokenKind.stringValue ||
        token.kind == TokenKind.blockStringValue) {
      final nextToken = _lookahead(1);

      switch (nextToken.kind) {
        case TokenKind.scalarKeyword:
        case TokenKind.typeKeyword:
        case TokenKind.interfaceKeyword:
        case TokenKind.unionKeyword:
        case TokenKind.enumKeyword:
        case TokenKind.inputKeyword:
          return _parseTypeDefinition();

        case TokenKind.directiveKeyword:
          return _parseDirectiveDefinition();
      }
    }

    throw Exception('Unexpected token $token!');
  }

  ast.SchemaDefinition _parseSchemaDefinition() {
    _expectToken(TokenKind.schemaKeyword);

    return ast.SchemaDefinition(
        directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
        definitions: _parseRootOperationTypeDefinitions());
  }

  Iterable<ast.RootOperationTypeDefinition>
      _parseRootOperationTypeDefinitions() => _many(TokenKind.bracketl,
          _parseRootOperationTypeDefinition, TokenKind.bracketr);

  ast.RootOperationTypeDefinition _parseRootOperationTypeDefinition() {
    final operation = _parseOperationType();

    _expectToken(TokenKind.colon);

    return ast.RootOperationTypeDefinition(
        operation: operation, value: _parseNamedType());
  }

  ast.OperationType _parseOperationType() =>
      ast.OperationType.fromTokenKind(_expectIdent().kind);

  ast.OperationDefinition _parseOperationDefinition() =>
      ast.OperationDefinition(
        operationType: _parseOperationType(),
        name: TokenKind.isIdentOrKeyword(_peek().kind) ? _parseName() : null,
        variableDefinitions:
            _isKindOf(TokenKind.parenl) ? _parseVariableDefinitions() : null,
        directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
        selectionSet: _parseSelectionSet(),
      );

  Iterable<ast.VariableDefinition> _parseVariableDefinitions() =>
      _many(TokenKind.parenl, _parseVariableDefinition, TokenKind.parenr);

  ast.VariableDefinition _parseVariableDefinition() {
    final variable = _parseVariable();

    _expectToken(TokenKind.colon);

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
      case TokenKind.ident:
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

  ast.NamedType _parseNamedType() => ast.NamedType(name: _parseName());

  ast.ListType _parseListType() {
    _expectToken(TokenKind.bracel);

    final type = ast.ListType(type: _parseType());

    _expectToken(TokenKind.bracer);

    return type;
  }

  ast.FragmentDefinition _parseFragmentDefinition() {
    _expectToken(TokenKind.fragmentKeyword);

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
        if (next.kind != TokenKind.onKeyword) {
          return _parseFragmentSpread();
        } else {
          return _parseInlineFragment();
        }
        break;

      case TokenKind.ident:
        return _parseField();
        break;

      default:
        throw Exception(
            'Expected identifier or ${TokenKind.spread} token, was ${_peek().kind}!');
    }
  }

  ast.InlineFragment _parseInlineFragment() {
    _expectToken(TokenKind.spread);

    final token = _peek();
    ast.TypeCondition typeCondition;

    if (token.kind == TokenKind.onKeyword) {
      typeCondition = _parseTypeCondition();
    }

    return ast.InlineFragment(
      typeCondition: typeCondition,
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
      selectionSet: _parseSelectionSet(),
    );
  }

  ast.TypeCondition _parseTypeCondition() {
    _expectToken(TokenKind.onKeyword);

    return ast.TypeCondition(name: _parseName());
  }

  ast.FragmentSpread _parseFragmentSpread() {
    _expectToken(TokenKind.spread);

    if (_isKindOf(TokenKind.onKeyword)) {
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
    final name = _parseName();

    _expectToken(TokenKind.colon);

    return ast.Alias(name: name);
  }

  Iterable<ast.Argument> _parseArguments() =>
      _many(TokenKind.parenl, _parseArgument, TokenKind.parenr);

  ast.Argument _parseArgument() {
    final name = _parseName();

    _expectToken(TokenKind.colon);

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

      case TokenKind.nullKeyword:
        _eatToken();
        return const ast.NullValue(null);

      case TokenKind.trueKeyword:
        _eatToken();
        return const ast.BooleanValue(true);

      case TokenKind.falseKeyword:
        _eatToken();
        return const ast.BooleanValue(false);

      case TokenKind.bracel:
        return _parseListValue(isConst: isConst);

      case TokenKind.bracketl:
        return _parseObjectValue(isConst: isConst);
    }

    if (TokenKind.isIdentOrKeyword(token.kind)) {
      return _parseEnumValue();
    }

    throw Exception('Unexpected token $token!');
  }

  ast.ListValue _parseListValue({bool isConst}) => ast.ListValue(_many(
          TokenKind.bracel,
          () => _parseValue(isConst: isConst),
          TokenKind.bracer)
      .toList(growable: false));

  ast.ObjectValue _parseObjectValue({bool isConst}) => ast.ObjectValue(_many(
      TokenKind.bracketl,
      () => _parseObjectField(isConst: isConst),
      TokenKind.bracketr));

  ast.ObjectField _parseObjectField({bool isConst}) {
    final name = _parseName();
    _expectToken(TokenKind.colon);

    return ast.ObjectField(
      name: name,
      value: _parseValue(isConst: isConst),
    );
  }

  ast.EnumValue _parseEnumValue() {
    final tok = _expectIdent();

    switch (tok.kind) {
      case TokenKind.nullKeyword:
      case TokenKind.trueKeyword:
      case TokenKind.falseKeyword:
        throw Exception('Unexpected token!');

      default:
        return ast.EnumValue(tok.value);
    }
  }

  ast.Variable _parseVariable() {
    _expectToken(TokenKind.dollar);

    return ast.Variable(name: _parseName());
  }

  Iterable<ast.Directive> _parseDirectives({bool isConst}) {
    final directives = <ast.Directive>[];

    do {
      directives.add(_parseDirective());
    } while (_isKindOf(TokenKind.at));

    return directives;
  }

  ast.Directive _parseDirective() {
    _expectToken(TokenKind.at);

    return ast.Directive(
      name: _parseName(),
      arguments: _isKindOf(TokenKind.parenl) ? _parseArguments() : null,
    );
  }

  ast.Node _parseTypeDefinition() {
    final hasDescription = _isKindOf(TokenKind.stringValue) ||
        _isKindOf(TokenKind.blockStringValue);
    final tok = hasDescription ? _lookahead(1) : _peek();

    switch (tok.kind) {
      case TokenKind.scalarKeyword:
        return _parseScalarTypeDefinition();

      case TokenKind.typeKeyword:
        return _parseObjectTypeDefinition();

      case TokenKind.interfaceKeyword:
        return _parseInterfaceTypeDefinition();

      case TokenKind.unionKeyword:
        return _parseUnionTypeDefinition();

      case TokenKind.enumKeyword:
        return _parseEnumTypeDefinition();

      case TokenKind.inputKeyword:
        return _parseInputObjectTypeDefinition();
    }

    throw Exception('Unexpected keyword!');
  }

  ast.Node _parseScalarTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectToken(TokenKind.scalarKeyword);

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

    _expectToken(TokenKind.typeKeyword);

    final name = _parseName();
    List<ast.NamedType> interfaces;

    if (_isOptionalKindOf(TokenKind.implementsKeyword)) {
      interfaces = [];

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

    return ast.FieldDefinition(
      description: description,
      name: name,
      arguments: arguments,
      type: _parseType(),
      directives: _isKindOf(TokenKind.at) ? _parseDirectives() : null,
    );
  }

  Iterable<ast.InputValueDefinition> _parseArgumentsDefinition() =>
      _many(TokenKind.parenl, _parseInputValueDefinition, TokenKind.parenr);

  ast.InputValueDefinition _parseInputValueDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;
    final name = _parseName();

    _expectToken(TokenKind.colon);

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

    _expectToken(TokenKind.interfaceKeyword);

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

    _expectToken(TokenKind.unionKeyword);

    final name = _parseName();
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    List<ast.NamedType> members;

    if (_isOptionalKindOf(TokenKind.eq)) {
      members = [];

      do {
        _isOptionalKindOf(TokenKind.pipe);
        members.add(_parseNamedType());
      } while (_isKindOf(TokenKind.pipe));
    }

    return ast.UnionTypeDefinition(
      description: description,
      name: name,
      directives: directives,
      members: members,
    );
  }

  ast.Node _parseEnumTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectToken(TokenKind.enumKeyword);

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

  ast.Node _parseInputObjectTypeDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectToken(TokenKind.inputKeyword);

    return ast.InputObjectTypeDefinition(
      name: _parseName(),
      description: description,
      directives:
          _isKindOf(TokenKind.at) ? _parseDirectives(isConst: true) : null,
      fields:
          _isKindOf(TokenKind.bracketl) ? _parseInputFieldsDefinition() : null,
    );
  }

  Iterable<ast.InputValueDefinition> _parseInputFieldsDefinition() =>
      _many(TokenKind.bracketl, _parseInputValueDefinition, TokenKind.bracketr);

  String _parseDescription() {
    if (!_isKindOf(TokenKind.stringValue) &&
        !_isKindOf(TokenKind.blockStringValue)) {
      throw Exception('Unexpected token!');
    }

    return _advanceToken().value;
  }

  ast.DirectiveDefinition _parseDirectiveDefinition() {
    final description = _isKindOf(TokenKind.stringValue) ||
            _isKindOf(TokenKind.blockStringValue)
        ? _parseDescription()
        : null;

    _expectToken(TokenKind.directiveKeyword);
    _expectToken(TokenKind.at);

    final name = _parseName();
    final arguments =
        _isKindOf(TokenKind.parenl) ? _parseArgumentsDefinition() : null;

    _expectToken(TokenKind.onKeyword);

    final locations = <ast.DirectiveLocation>[];

    do {
      _isOptionalKindOf(TokenKind.pipe);
      locations.add(ast.DirectiveLocation.fromString(_parseName()));
    } while (_peek().kind == TokenKind.pipe);

    return ast.DirectiveDefinition(
      description: description,
      name: name,
      arguments: arguments,
      locations: locations,
    );
  }

  ast.Node _parseTypeExtension() {
    final nextToken = _lookahead(1);

    switch (nextToken.kind) {
      case TokenKind.scalarKeyword:
        return _parseScalarTypeExtension();

      case TokenKind.interfaceKeyword:
        return _parseInterfaceTypeExtension();

      case TokenKind.enumKeyword:
        return _parseEnumTypeExtension();

      case TokenKind.unionKeyword:
        return _parseUnionTypeExtension();

      case TokenKind.typeKeyword:
        return _parseObjectTypeExtension();

      case TokenKind.inputKeyword:
        return _parseInputObjectTypeExtension();
        break;
    }

    throw Exception('Unexpected token!');
  }

  ast.SchemaExtension _parseSchemaExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.schemaKeyword);

    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    final definitions = _isKindOf(TokenKind.bracketl)
        ? _parseRootOperationTypeDefinitions()
        : null;

    if (directives == null && definitions == null) {
      throw Exception(
          'Expected either directives or definitions, found nothing!');
    }

    return ast.SchemaExtension(
      directives: directives,
      definitions: definitions,
    );
  }

  ast.ScalarTypeExtension _parseScalarTypeExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.scalarKeyword);

    return ast.ScalarTypeExtension(
      name: _parseName(),
      directives: _parseDirectives(),
    );
  }

  ast.ObjectTypeExtension _parseObjectTypeExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.typeKeyword);

    final name = _parseName();
    List<ast.NamedType> interfaces;

    if (_isOptionalKindOf(TokenKind.implementsKeyword)) {
      interfaces = [];

      if (_peek().kind == TokenKind.amp) {
        _eatToken();
      }

      do {
        interfaces.add(_parseNamedType());
      } while (_isOptionalKindOf(TokenKind.amp));
    }

    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    final fields =
        _isKindOf(TokenKind.bracketl) ? _parseFieldsDefinition() : null;

    if (interfaces == null && directives == null && fields == null) {
      throw Exception(
          'Expected implements or directives, or fields, found nothing!');
    }

    return ast.ObjectTypeExtension(
      name: name,
      interfaces: interfaces,
      directives: directives,
      fields: fields,
    );
  }

  ast.InterfaceTypeExtension _parseInterfaceTypeExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.interfaceKeyword);

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
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.enumKeyword);

    final name = _parseName();
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    final values =
        _isKindOf(TokenKind.bracketl) ? _parseEnumValuesDefinition() : null;

    if (directives == null && values == null) {
      throw Exception('Expected either directives or field definitions!');
    }

    return ast.EnumTypeExtension(
        name: name, values: values, directives: directives);
  }

  ast.UnionTypeExtension _parseUnionTypeExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.unionKeyword);

    final name = _parseName();
    final directives = _isKindOf(TokenKind.at) ? _parseDirectives() : null;
    List<ast.NamedType> members;

    if (_isOptionalKindOf(TokenKind.eq)) {
      members = [];

      do {
        _isOptionalKindOf(TokenKind.pipe);
        members.add(_parseNamedType());
      } while (_isKindOf(TokenKind.pipe));
    }

    if (directives == null && members == null) {
      throw Exception('Expected either directives or members, found nothing!');
    }

    return ast.UnionTypeExtension(
      name: name,
      directives: directives,
      members: members,
    );
  }

  ast.InputObjectTypeExtension _parseInputObjectTypeExtension() {
    _expectToken(TokenKind.extendKeyword);
    _expectToken(TokenKind.inputKeyword);

    final name = _parseName();
    final directives =
        _isKindOf(TokenKind.at) ? _parseDirectives(isConst: true) : null;
    final fields =
        _isKindOf(TokenKind.bracketl) ? _parseInputFieldsDefinition() : null;

    if (directives == null && fields == null) {
      throw Exception('Expected either directives or members, found nothing!');
    }

    return ast.InputObjectTypeExtension(
      name: name,
      directives: directives,
      fields: fields,
    );
  }
}

ast.Document parse(Source source) => Parser(source).parse();
