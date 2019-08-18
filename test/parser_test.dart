import 'dart:convert' show json;

import 'package:graphite_language/ast.dart' as ast;
import 'package:graphite_language/parser.dart';
import 'package:graphite_language/token.dart';
import 'package:test/test.dart';

dynamic convertSourceToMap(String code) =>
    json.decode(json.encode(parse(Source(body: code))));

dynamic convertAstToMap(ast.Node node) => json.decode(json.encode(node));

void main() {
  group('Parser', () {
    group('SelectionSet', () {
      test('parses selection set', () {
        expect(
            convertSourceToMap('{ user { id, name } }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SelectionSet(selections: [
                ast.Field(
                    name: 'user',
                    selectionSet: ast.SelectionSet(selections: [
                      ast.Field(name: 'id'),
                      ast.Field(name: 'name')
                    ]))
              ])
            ])));
      });
    });

    group('SchemaDefinition', () {
      test('parses simple definition', () {
        expect(() => convertSourceToMap('schema { name: HelloWorld }'), throws);
        expect(() => convertSourceToMap('schema { name HelloWorld }'), throws);
        expect(() => convertSourceToMap('schema { name }'), throws);
        expect(() => convertSourceToMap('schema {'), throws);
        expect(() => convertSourceToMap('schema }'), throws);

        expect(
            convertSourceToMap('schema { query: Query }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SchemaDefinition(definitions: [
                ast.RootOperationTypeDefinition(
                  operation: ast.OperationType.query,
                  value: ast.NamedType(name: 'Query'),
                )
              ])
            ])));

        expect(
            convertSourceToMap('schema @one @two @three {'
                'mutation: Mutation,'
                'query: Query'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SchemaDefinition(definitions: [
                ast.RootOperationTypeDefinition(
                    operation: ast.OperationType.mutation,
                    value: ast.NamedType(name: 'Mutation')),
                ast.RootOperationTypeDefinition(
                    operation: ast.OperationType.query,
                    value: ast.NamedType(name: 'Query')),
              ], directives: [
                ast.Directive(name: 'one'),
                ast.Directive(name: 'two'),
                ast.Directive(name: 'three')
              ])
            ])));
      });
    });

    group('OperationDefinition', () {
      test('parses simple operation', () {
        expect(() => convertSourceToMap('query {}'), throws);

        expect(
            convertSourceToMap('query Foo { field }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.OperationDefinition(
                  name: 'Foo',
                  operationType: ast.OperationType.query,
                  selectionSet:
                      ast.SelectionSet(selections: [ast.Field(name: 'field')]))
            ])));
      });

      test('parses complex operation with variables', () {
        expect(
            convertSourceToMap('query Foo(\$foo: String, \$bar: String) {\n'
                '    foo(bar: \$bar) { xyz(foo: \$foo) { bar } }\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.OperationDefinition(
                  name: 'Foo',
                  operationType: ast.OperationType.query,
                  variableDefinitions: [
                    ast.VariableDefinition(
                      variable: ast.Variable(name: 'foo'),
                      type: ast.NamedType(name: 'String'),
                    ),
                    ast.VariableDefinition(
                      variable: ast.Variable(name: 'bar'),
                      type: ast.NamedType(name: 'String'),
                    )
                  ],
                  selectionSet: ast.SelectionSet(selections: [
                    ast.Field(
                        name: 'foo',
                        arguments: [
                          ast.Argument(
                              name: 'bar', value: ast.Variable(name: 'bar'))
                        ],
                        selectionSet: ast.SelectionSet(selections: [
                          ast.Field(
                              name: 'xyz',
                              arguments: [
                                ast.Argument(
                                    name: 'foo',
                                    value: ast.Variable(name: 'foo'))
                              ],
                              selectionSet: ast.SelectionSet(
                                  selections: [ast.Field(name: 'bar')]))
                        ]))
                  ]))
            ])));
      });

      test('parses operations with directives', () {
        expect(() => convertSourceToMap('query @foo @bar'), throws);
        expect(() => convertSourceToMap('query @foo @bar {}'), throws);
        expect(() => convertSourceToMap('query @foo Bar'), throws);
        expect(() => convertSourceToMap('query Bar @foo {}'), throws);

        expect(
            convertSourceToMap('query @foo { bar }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.OperationDefinition(
                  operationType: ast.OperationType.query,
                  directives: [ast.Directive(name: 'foo')],
                  selectionSet:
                      ast.SelectionSet(selections: [ast.Field(name: 'bar')]))
            ])));

        expect(
            convertSourceToMap('mutation Baz @foo @bar { ...xyz }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.OperationDefinition(
                  operationType: ast.OperationType.mutation,
                  name: 'Baz',
                  directives: [
                    ast.Directive(name: 'foo'),
                    ast.Directive(name: 'bar')
                  ],
                  selectionSet: ast.SelectionSet(
                      selections: [ast.FragmentSpread(name: 'xyz')]))
            ])));
      });
    });

    group('ScalarTypeDefinition', () {
      test('parses definition', () {
        expect(() => convertSourceToMap('scalar'), throws);

        expect(
            convertSourceToMap('scalar Foo'),
            convertAstToMap(const ast.Document(
                definitions: [ast.ScalarTypeDefinition(name: 'Foo')])));

        expect(
            convertSourceToMap('"""Foo""" scalar Foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ScalarTypeDefinition(name: 'Foo', description: 'Foo')
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('scalar "Foo" Foo'), throws);
        expect(() => convertSourceToMap('scalar """Foo""" Foo'), throws);
        expect(() => convertSourceToMap('scalar @foo'), throws);
        expect(() => convertSourceToMap('scalar @foo Foo'), throws);
        expect(() => convertSourceToMap('scalar @foo """Foo""" Foo'), throws);

        expect(
            convertSourceToMap('scalar Foo @bar @baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ScalarTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz')
              ])
            ])));
      });
    });

    group('ObjectTypeDefinition', () {
      test('parses definition', () {
        expect(() => convertSourceToMap('type'), throws);
        expect(() => convertSourceToMap('type """Foo"""'), throws);
        expect(() => convertSourceToMap('type Name {}'), throws);

        expect(
            convertSourceToMap('type Foo'),
            convertAstToMap(const ast.Document(
                definitions: [ast.ObjectTypeDefinition(name: 'Foo')])));

        expect(
            convertSourceToMap('"""Foo""" type Foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', description: 'Foo')
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('type @foo @bar Foo'), throws);
        expect(() => convertSourceToMap('type Foo @foo @bar {}'), throws);

        expect(
            convertSourceToMap('"""Foo""" type Foo @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(
                  name: 'Foo',
                  description: 'Foo',
                  directives: [
                    ast.Directive(name: 'foo'),
                    ast.Directive(name: 'bar')
                  ])
            ])));

        expect(
            convertSourceToMap('"""Foo""" type Foo @baz { bar: Bar }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(
                  name: 'Foo',
                  description: 'Foo',
                  directives: [
                    ast.Directive(name: 'baz'),
                  ],
                  fields: [
                    ast.FieldDefinition(
                        name: 'bar', type: ast.NamedType(name: 'Bar'))
                  ])
            ])));
      });

      test('parses definition with fields', () {
        expect(() => convertSourceToMap('type Foo { foo: Foo """Foo""" }'),
            throws);
        expect(() => convertSourceToMap('type Foo { foo: @foo }'), throws);

        expect(
            convertSourceToMap('type Foo {'
                '  foo: Foo @foo\n'
                '  bar: Bar\n'
                '  baz: Baz @baz @xyz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    directives: [ast.Directive(name: 'foo')]),
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'Bar')),
                ast.FieldDefinition(
                    name: 'baz',
                    type: ast.NamedType(name: 'Baz'),
                    directives: [
                      ast.Directive(name: 'baz'),
                      ast.Directive(name: 'xyz')
                    ])
              ])
            ])));

        expect(
            convertSourceToMap('type Foo @foo {'
                '  """Bar""" bar: Bar\n'
                '  xyz: XYZ'
                '  "Baz" baz: Baz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'foo')
              ], fields: [
                ast.FieldDefinition(
                    name: 'bar',
                    description: 'Bar',
                    type: ast.NamedType(name: 'Bar')),
                ast.FieldDefinition(
                    name: 'xyz', type: ast.NamedType(name: 'XYZ')),
                ast.FieldDefinition(
                    name: 'baz',
                    description: 'Baz',
                    type: ast.NamedType(name: 'Baz'))
              ])
            ])));
      });

      test('parses definition with `implements`', () {
        expect(() => convertSourceToMap('type Foo & Bar'), throws);
        expect(() => convertSourceToMap('type Foo implements & & Bar'), throws);
        expect(() => convertSourceToMap('type Foo implements & Bar &'), throws);
        expect(
            () => convertSourceToMap('type Foo implements Baz implements Bar'),
            throws);
        expect(() => convertSourceToMap('type Foo implements Baz {}'), throws);

        expect(
            convertSourceToMap('type Foo implements Bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(
                  name: 'Foo', interfaces: [ast.NamedType(name: 'Bar')])
            ])));

        expect(
            convertSourceToMap('type Foo implements & Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(
                  name: 'Foo', interfaces: [ast.NamedType(name: 'Baz')])
            ])));

        expect(
            convertSourceToMap('type Foo implements Bar & Baz @foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', interfaces: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz')
              ], directives: [
                ast.Directive(name: 'foo')
              ])
            ])));
        expect(
            convertSourceToMap('type Foo implements Bar & Baz & Xyz {\n'
                'foo: Foo\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', interfaces: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz'),
                ast.NamedType(name: 'Xyz')
              ], fields: [
                ast.FieldDefinition(
                    name: 'foo', type: ast.NamedType(name: 'Foo'))
              ])
            ])));
      });

      test('parses definition with fields with arguments', () {
        expect(
            convertSourceToMap('type Foo {\n'
                '  foo(bar: ID!): Foo\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    arguments: [
                      ast.InputValueDefinition(
                          name: 'bar',
                          type:
                              ast.NonNullType(type: ast.NamedType(name: 'ID')))
                    ])
              ])
            ])));

        expect(
            convertSourceToMap('type Foo {\n'
                '  foo(bar: String @baz @xyz, baz: [Int!]): Foo\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    arguments: [
                      ast.InputValueDefinition(
                          name: 'bar',
                          directives: [
                            ast.Directive(name: 'baz'),
                            ast.Directive(name: 'xyz')
                          ],
                          type: ast.NamedType(name: 'String')),
                      ast.InputValueDefinition(
                          name: 'baz',
                          type: ast.ListType(
                              type: ast.NonNullType(
                                  type: ast.NamedType(name: 'Int'))))
                    ])
              ])
            ])));

        expect(
            convertSourceToMap('type Foo {\n'
                '  foo(bar: ID = "abc" @baz): Foo\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeDefinition(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    arguments: [
                      ast.InputValueDefinition(
                          name: 'bar',
                          defaultValue: ast.StringValue('abc'),
                          directives: [ast.Directive(name: 'baz')],
                          type: ast.NamedType(name: 'ID'))
                    ])
              ])
            ])));
      });
    });

    group('InterfaceTypeDefinition', () {
      test('parses simple definition', () {
        expect(() => convertSourceToMap('inteface "description" Foo'), throws);
        expect(() => convertSourceToMap('inteface Foo {}'), throws);

        expect(
            convertSourceToMap('interface Foo'),
            convertAstToMap(const ast.Document(
                definitions: [ast.InterfaceTypeDefinition(name: 'Foo')])));

        expect(
            convertSourceToMap('interface Foo { bar: [[String]!]! }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeDefinition(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'bar',
                    type: ast.NonNullType(
                        type: ast.ListType(
                            type: ast.NonNullType(
                                type: ast.ListType(
                                    type: ast.NamedType(name: 'String'))))))
              ])
            ])));

        expect(
            convertSourceToMap(
                '"""Interface Foo""" interface Foo { "bar property" bar: Int }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeDefinition(
                  name: 'Foo',
                  description: 'Interface Foo',
                  fields: [
                    ast.FieldDefinition(
                        name: 'bar',
                        description: 'bar property',
                        type: ast.NamedType(name: 'Int'))
                  ])
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('interface @foo'), throws);
        expect(() => convertSourceToMap('interface Foo @baz {}'), throws);
        expect(() => convertSourceToMap('interface Foo { bar: String } @baz'),
            throws);

        expect(
            convertSourceToMap('interface Foo @foo @baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'baz')
              ])
            ])));

        expect(
            convertSourceToMap('interface Foo @xyz { bar: String }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'xyz'),
              ], fields: [
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'String'))
              ])
            ])));
      });
    });

    group('InputObjectTypeDefinition', () {
      test('parses definition', () {
        expect(() => convertSourceToMap('input'), throws);
        expect(() => convertSourceToMap('input """Foo"""'), throws);
        expect(() => convertSourceToMap('input Name {}'), throws);

        expect(
            convertSourceToMap('input Foo'),
            convertAstToMap(const ast.Document(
                definitions: [ast.InputObjectTypeDefinition(name: 'Foo')])));

        expect(
            convertSourceToMap('"""Foo""" input Foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeDefinition(name: 'Foo', description: 'Foo')
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('input @foo @bar Foo'), throws);
        expect(() => convertSourceToMap('input Foo @foo @bar {}'), throws);

        expect(
            convertSourceToMap('"""Foo""" input Foo @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeDefinition(
                  name: 'Foo',
                  description: 'Foo',
                  directives: [
                    ast.Directive(name: 'foo'),
                    ast.Directive(name: 'bar')
                  ])
            ])));

        expect(
            convertSourceToMap('"""Foo""" input Foo @baz { bar: Bar }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeDefinition(
                  name: 'Foo',
                  description: 'Foo',
                  directives: [
                    ast.Directive(name: 'baz'),
                  ],
                  fields: [
                    ast.InputValueDefinition(
                        name: 'bar', type: ast.NamedType(name: 'Bar'))
                  ])
            ])));
      });

      test('parses definition with fields', () {
        expect(() => convertSourceToMap('input Foo { foo: Foo """Foo""" }'),
            throws);
        expect(() => convertSourceToMap('input Foo { foo: @foo }'), throws);

        expect(
            convertSourceToMap('input Foo {'
                '  foo: Foo @foo\n'
                '  bar: Bar\n'
                '  baz: Baz @baz @xyz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeDefinition(name: 'Foo', fields: [
                ast.InputValueDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    directives: [ast.Directive(name: 'foo')]),
                ast.InputValueDefinition(
                    name: 'bar', type: ast.NamedType(name: 'Bar')),
                ast.InputValueDefinition(
                    name: 'baz',
                    type: ast.NamedType(name: 'Baz'),
                    directives: [
                      ast.Directive(name: 'baz'),
                      ast.Directive(name: 'xyz')
                    ])
              ])
            ])));

        expect(
            convertSourceToMap('input Foo @foo {'
                '  """Bar""" bar: Bar\n'
                '  xyz: XYZ'
                '  "Baz" baz: Baz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'foo')
              ], fields: [
                ast.InputValueDefinition(
                    name: 'bar',
                    description: 'Bar',
                    type: ast.NamedType(name: 'Bar')),
                ast.InputValueDefinition(
                    name: 'xyz', type: ast.NamedType(name: 'XYZ')),
                ast.InputValueDefinition(
                    name: 'baz',
                    description: 'Baz',
                    type: ast.NamedType(name: 'Baz'))
              ])
            ])));
      });
    });

    group('UnionTypeDefinition', () {
      test('parses simple definition', () {
        expect(() => convertSourceToMap('union Foo FOO'), throws);

        expect(
            convertSourceToMap('union Foo'),
            convertAstToMap(const ast.Document(
                definitions: [ast.UnionTypeDefinition(name: 'Foo')])));

        expect(
            convertSourceToMap('"""Foo""" union Foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeDefinition(description: 'Foo', name: 'Foo')
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('union @foo Foo'), throws);
        expect(() => convertSourceToMap('union @foo Foo'), throws);

        expect(
            convertSourceToMap('union Foo @foo(bar: "String") @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeDefinition(name: 'Foo', directives: [
                ast.Directive(name: 'foo', arguments: [
                  ast.Argument(name: 'bar', value: ast.StringValue('String'))
                ]),
                ast.Directive(name: 'bar')
              ])
            ])));
      });

      test('parses definition with members', () {
        expect(() => convertSourceToMap('union Foo Bar | Baz'), throws);
        expect(() => convertSourceToMap('union Foo @foo Bar | Baz'), throws);

        expect(
            convertSourceToMap('union Foo = Bar | Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeDefinition(name: 'Foo', members: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz')
              ])
            ])));

        expect(
            convertSourceToMap('union Foo = | Bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeDefinition(name: 'Foo', members: [
                ast.NamedType(name: 'Bar'),
              ])
            ])));

        expect(
            convertSourceToMap(
                '"Foo union" union Foo @foo @bar @baz @xyz = Bar | Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeDefinition(
                  description: 'Foo union',
                  name: 'Foo',
                  directives: [
                    ast.Directive(name: 'foo'),
                    ast.Directive(name: 'bar'),
                    ast.Directive(name: 'baz'),
                    ast.Directive(name: 'xyz')
                  ],
                  members: [
                    ast.NamedType(name: 'Bar'),
                    ast.NamedType(name: 'Baz')
                  ])
            ])));
      });
    });

    group('EnumTypeDefinition', () {
      test('parses simple definition', () {
        expect(
            convertSourceToMap('enum Direction {\n'
                ' NORTH\n'
                ' EAST\n'
                ' SOUTH\n'
                ' WEST\n'
                '}\n'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeDefinition(name: 'Direction', values: [
                ast.EnumValueDefinition(value: ast.EnumValue('NORTH')),
                ast.EnumValueDefinition(value: ast.EnumValue('EAST')),
                ast.EnumValueDefinition(value: ast.EnumValue('SOUTH')),
                ast.EnumValueDefinition(value: ast.EnumValue('WEST'))
              ])
            ])));

        expect(
            convertSourceToMap('"enum Baz" enum Baz {\n'
                '  """xyz description"""'
                '  XYZ\n'
                '  "foo description"'
                '  foo\n'
                '}\n'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeDefinition(
                  name: 'Baz',
                  description: 'enum Baz',
                  values: [
                    ast.EnumValueDefinition(
                        value: ast.EnumValue('XYZ'),
                        description: 'xyz description'),
                    ast.EnumValueDefinition(
                        value: ast.EnumValue('foo'),
                        description: 'foo description'),
                  ])
            ])));
      });

      test('parses definition with directives', () {
        expect(
            convertSourceToMap('enum FooBar @foo @bar @baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeDefinition(name: 'FooBar', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz')
              ])
            ])));

        expect(
            convertSourceToMap('enum FooBar @xyz { FOO @foo, BAR @bar @baz }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeDefinition(name: 'FooBar', directives: [
                ast.Directive(name: 'xyz'),
              ], values: [
                ast.EnumValueDefinition(
                    value: ast.EnumValue('FOO'),
                    directives: [ast.Directive(name: 'foo')]),
                ast.EnumValueDefinition(
                    value: ast.EnumValue('BAR'),
                    directives: [
                      ast.Directive(name: 'bar'),
                      ast.Directive(name: 'baz')
                    ])
              ])
            ])));
      });
    });

    group('DirectiveDefinition', () {
      test('parses simple definition', () {
        expect(() => convertSourceToMap('directive @Bar'), throws);
        expect(() => convertSourceToMap('directive Bar on QUERY'), throws);
        expect(
            () => convertSourceToMap('directive @Foo on QUERY | BAR'), throws);
        expect(() => convertSourceToMap('directive @Foo on FOO'), throws);

        expect(
            convertSourceToMap(
                '"""Directive description""" directive @Foo on QUERY'),
            convertAstToMap(const ast.Document(definitions: [
              ast.DirectiveDefinition(
                  name: 'Foo',
                  description: 'Directive description',
                  locations: [ast.DirectiveLocation.query])
            ])));

        expect(
            convertSourceToMap(
                'directive @QUERY on MUTATION | SUBSCRIPTION | FIELD | SCHEMA'),
            convertAstToMap(const ast.Document(definitions: [
              ast.DirectiveDefinition(name: 'QUERY', locations: [
                ast.DirectiveLocation.mutation,
                ast.DirectiveLocation.subscription,
                ast.DirectiveLocation.field,
                ast.DirectiveLocation.schema
              ])
            ])));

        expect(
            convertSourceToMap(
                '"""Directive description""" directive @FooBar on | QUERY | MUTATION'),
            convertAstToMap(const ast.Document(definitions: [
              ast.DirectiveDefinition(
                  name: 'FooBar',
                  description: 'Directive description',
                  locations: [
                    ast.DirectiveLocation.query,
                    ast.DirectiveLocation.mutation
                  ])
            ])));
      });

      test('parses with arguments', () {
        expect(
            () => convertSourceToMap('directive @FooBar ( on QUERY'), throws);
        expect(
            () => convertSourceToMap('directive @FooBar () on QUERY'), throws);
        expect(
            () => convertSourceToMap(
                'directive @FooBar (foo: Int! = 123) on BAR'),
            throws);

        expect(
            convertSourceToMap(
                'directive @Foo (foo: ID = 123, bar: String @bar) on QUERY'),
            convertAstToMap(const ast.Document(definitions: [
              ast.DirectiveDefinition(name: 'Foo', arguments: [
                ast.InputValueDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'ID'),
                    defaultValue: ast.IntValue(123)),
                ast.InputValueDefinition(
                    name: 'bar',
                    type: ast.NamedType(name: 'String'),
                    directives: [ast.Directive(name: 'bar')])
              ], locations: [
                ast.DirectiveLocation.query,
              ])
            ])));
      });
    });

    // Extensions
    // ------------------------------------------------------------------------

    group('SchemaExtension', () {
      test('parses simple extension', () {
        expect(() => convertSourceToMap('extend schema { name: HelloWorld }'),
            throws);
        expect(() => convertSourceToMap('extend schema { name HelloWorld }'),
            throws);
        expect(() => convertSourceToMap('extend schema { name }'), throws);

        expect(
            convertSourceToMap('extend schema { query: Query }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SchemaExtension(definitions: [
                ast.RootOperationTypeDefinition(
                  operation: ast.OperationType.query,
                  value: ast.NamedType(name: 'Query'),
                )
              ])
            ])));
      });

      test('parse extension with directives', () {
        expect(
            convertSourceToMap('extend schema @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SchemaExtension(directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar')
              ])
            ])));

        expect(
            convertSourceToMap('extend schema @one @two @three {'
                'mutation: Mutation,'
                'query: Query'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.SchemaExtension(definitions: [
                ast.RootOperationTypeDefinition(
                    operation: ast.OperationType.mutation,
                    value: ast.NamedType(name: 'Mutation')),
                ast.RootOperationTypeDefinition(
                    operation: ast.OperationType.query,
                    value: ast.NamedType(name: 'Query')),
              ], directives: [
                ast.Directive(name: 'one'),
                ast.Directive(name: 'two'),
                ast.Directive(name: 'three')
              ])
            ])));
      });
    });

    group('ScalarTypeExtension', () {
      test('parses extension', () {
        expect(() => convertSourceToMap('extend scalar Foo'), throws);
        expect(() => convertSourceToMap('extend scalar @foo'), throws);
        expect(() => convertSourceToMap('extend scalar @foo Foo'), throws);

        expect(
            convertSourceToMap('extend scalar Foo @bar @baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ScalarTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz')
              ])
            ])));
      });
    });

    group('InterfaceTypeExtension', () {
      test('parses simple extension', () {
        expect(() => convertSourceToMap('extend interface Foo'), throws);
        expect(() => convertSourceToMap('extend interface Foo {}'), throws);
        expect(
            () => convertSourceToMap(
                '"""Hello world""" extend interface Foo { HelloWorld: HelloWorld }'),
            throws);

        expect(
            convertSourceToMap(
                'extend interface Foo { bar: String, baz: HelloWorld }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeExtension(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'String')),
                ast.FieldDefinition(
                    name: 'baz', type: ast.NamedType(name: 'HelloWorld')),
              ])
            ])));
      });

      test('parses extension with directives', () {
        expect(
            convertSourceToMap('extend interface Foo @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar')
              ])
            ])));

        expect(
            convertSourceToMap('extend interface Foo @foo { bar: String }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InterfaceTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo')
              ], fields: [
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'String'))
              ])
            ])));
      });
    });

    group('UnionTypeExtension', () {
      test('parses simple definition', () {
        expect(() => convertSourceToMap('extend union Foo FOO'), throws);
        expect(() => convertSourceToMap('extend union Name'), throws);
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('extend union @foo Foo'), throws);

        expect(
            convertSourceToMap('extend union Foo @foo(bar: "String") @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo', arguments: [
                  ast.Argument(name: 'bar', value: ast.StringValue('String'))
                ]),
                ast.Directive(name: 'bar')
              ])
            ])));
      });

      test('parses definition with members', () {
        expect(() => convertSourceToMap('extend union Foo Bar | Baz'), throws);
        expect(() => convertSourceToMap('extend union Foo @foo Bar | Baz'),
            throws);

        expect(
            convertSourceToMap('extend union Foo = Bar | Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeExtension(name: 'Foo', members: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz')
              ])
            ])));

        expect(
            convertSourceToMap('extend union Foo = | Bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeExtension(name: 'Foo', members: [
                ast.NamedType(name: 'Bar'),
              ])
            ])));

        expect(
            convertSourceToMap(
                'extend union Foo @foo @bar @baz @xyz = Bar | Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.UnionTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz'),
                ast.Directive(name: 'xyz')
              ], members: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz')
              ])
            ])));
      });
    });

    group('EnumTypeExtension', () {
      test('parses simple extension', () {
        expect(() => convertSourceToMap('extend enum Foo'), throws);
        expect(
            () => convertSourceToMap(
                '"""description""" extend enum Foo { bar: string }'),
            throws);

        expect(
            convertSourceToMap('extend enum Direction {\n'
                '  "North"'
                ' NORTH\n'
                ' EAST\n'
                ' SOUTH\n'
                ' WEST\n'
                '}\n'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeExtension(name: 'Direction', values: [
                ast.EnumValueDefinition(
                    description: 'North', value: ast.EnumValue('NORTH')),
                ast.EnumValueDefinition(value: ast.EnumValue('EAST')),
                ast.EnumValueDefinition(value: ast.EnumValue('SOUTH')),
                ast.EnumValueDefinition(value: ast.EnumValue('WEST'))
              ])
            ])));
      });

      test('parses definition with directives', () {
        expect(() => convertSourceToMap('extend enum Foo { bar: Bar } @foo'),
            throws);

        expect(
            convertSourceToMap('extend enum FooBar @foo @bar @baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeExtension(name: 'FooBar', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz')
              ])
            ])));

        expect(
            convertSourceToMap(
                'extend enum FooBar @xyz { FOO @foo, BAR @bar @baz }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeExtension(name: 'FooBar', directives: [
                ast.Directive(name: 'xyz'),
              ], values: [
                ast.EnumValueDefinition(
                    value: ast.EnumValue('FOO'),
                    directives: [ast.Directive(name: 'foo')]),
                ast.EnumValueDefinition(
                    value: ast.EnumValue('BAR'),
                    directives: [
                      ast.Directive(name: 'bar'),
                      ast.Directive(name: 'baz')
                    ])
              ])
            ])));
      });
    });

    group('ObjectTypeExtension', () {
      test('parses definition with directives', () {
        expect(() => convertSourceToMap('extend type @foo @bar Foo'), throws);
        expect(
            () => convertSourceToMap('extend type Foo @foo @bar {}'), throws);

        expect(
            convertSourceToMap('extend type Foo @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar')
              ])
            ])));

        expect(
            convertSourceToMap('extend type Foo @baz { bar: Bar }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'baz'),
              ], fields: [
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'Bar'))
              ])
            ])));
      });

      test('parses definition with fields', () {
        expect(() => convertSourceToMap('extend type'), throws);
        expect(() => convertSourceToMap('extend type """Foo"""'), throws);
        expect(() => convertSourceToMap('extend type Name {}'), throws);
        expect(() => convertSourceToMap('extend type Foo'), throws);
        expect(() => convertSourceToMap('"""Foo""" extend type Foo'), throws);
        expect(
            () => convertSourceToMap('extend type Foo { foo: Foo """Foo""" }'),
            throws);
        expect(
            () => convertSourceToMap('extend type Foo { foo: @foo }'), throws);

        expect(
            convertSourceToMap('extend type Foo {'
                '  foo: Foo @foo\n'
                '  bar: Bar\n'
                '  baz: Baz @baz @xyz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', fields: [
                ast.FieldDefinition(
                    name: 'foo',
                    type: ast.NamedType(name: 'Foo'),
                    directives: [ast.Directive(name: 'foo')]),
                ast.FieldDefinition(
                    name: 'bar', type: ast.NamedType(name: 'Bar')),
                ast.FieldDefinition(
                    name: 'baz',
                    type: ast.NamedType(name: 'Baz'),
                    directives: [
                      ast.Directive(name: 'baz'),
                      ast.Directive(name: 'xyz')
                    ])
              ])
            ])));

        expect(
            convertSourceToMap('extend type Foo @foo {'
                '  """Bar""" bar: Bar\n'
                '  xyz: XYZ'
                '  "Baz" baz: Baz\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo')
              ], fields: [
                ast.FieldDefinition(
                    name: 'bar',
                    description: 'Bar',
                    type: ast.NamedType(name: 'Bar')),
                ast.FieldDefinition(
                    name: 'xyz', type: ast.NamedType(name: 'XYZ')),
                ast.FieldDefinition(
                    name: 'baz',
                    description: 'Baz',
                    type: ast.NamedType(name: 'Baz'))
              ])
            ])));
      });

      test('parses definition with `implements`', () {
        expect(() => convertSourceToMap('extend type Foo & Bar'), throws);
        expect(() => convertSourceToMap('extend type Foo implements & & Bar'),
            throws);
        expect(() => convertSourceToMap('extend type Foo implements & Bar &'),
            throws);
        expect(
            () => convertSourceToMap(
                'extend type Foo implements Baz implements Bar'),
            throws);
        expect(() => convertSourceToMap('extend type Foo implements Baz {}'),
            throws);

        expect(
            convertSourceToMap('extend type Foo implements Bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(
                  name: 'Foo', interfaces: [ast.NamedType(name: 'Bar')])
            ])));

        expect(
            convertSourceToMap('extend type Foo implements & Baz'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(
                  name: 'Foo', interfaces: [ast.NamedType(name: 'Baz')])
            ])));

        expect(
            convertSourceToMap('extend type Foo implements Bar & Baz @foo'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', interfaces: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz')
              ], directives: [
                ast.Directive(name: 'foo')
              ])
            ])));
        expect(
            convertSourceToMap('extend type Foo implements Bar & Baz & Xyz {\n'
                'foo: Foo\n'
                '}'),
            convertAstToMap(const ast.Document(definitions: [
              ast.ObjectTypeExtension(name: 'Foo', interfaces: [
                ast.NamedType(name: 'Bar'),
                ast.NamedType(name: 'Baz'),
                ast.NamedType(name: 'Xyz')
              ], fields: [
                ast.FieldDefinition(
                    name: 'foo', type: ast.NamedType(name: 'Foo'))
              ])
            ])));
      });
    });

    group('InputObjectTypeExtension', () {
      test('parses extension with fields', () {
        expect(() => convertSourceToMap('extend input Foo'), throws);
        expect(() => convertSourceToMap('extend input Foo {}'), throws);
        expect(
            () => convertSourceToMap(
                '"""Hello world""" extend input Foo { HelloWorld: HelloWorld }'),
            throws);

        expect(
            convertSourceToMap(
                'extend input Foo { bar: String, baz: HelloWorld }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeExtension(name: 'Foo', fields: [
                ast.InputValueDefinition(
                    name: 'bar', type: ast.NamedType(name: 'String')),
                ast.InputValueDefinition(
                    name: 'baz', type: ast.NamedType(name: 'HelloWorld')),
              ])
            ])));
      });

      test('parses extension with directives', () {
        expect(
            convertSourceToMap('extend input Foo @foo @bar'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar')
              ])
            ])));

        expect(
            convertSourceToMap('extend input Foo @foo { bar: String }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.InputObjectTypeExtension(name: 'Foo', directives: [
                ast.Directive(name: 'foo')
              ], fields: [
                ast.InputValueDefinition(
                    name: 'bar', type: ast.NamedType(name: 'String'))
              ])
            ])));
      });
    });
  });
}
