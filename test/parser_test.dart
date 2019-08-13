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
      test('parses schema definition', () {
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
            convertSourceToMap('enum FooBar @foo @bar @baz { FOO, BAR }'),
            convertAstToMap(const ast.Document(definitions: [
              ast.EnumTypeDefinition(name: 'FooBar', directives: [
                ast.Directive(name: 'foo'),
                ast.Directive(name: 'bar'),
                ast.Directive(name: 'baz')
              ], values: [
                ast.EnumValueDefinition(value: ast.EnumValue('FOO')),
                ast.EnumValueDefinition(value: ast.EnumValue('BAR'))
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

    // Extensions
    // ------------------------------------------------------------------------

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

    group('ObjectTypeExtension', () {
      test('parses extension', () {
        expect(() => convertSourceToMap('extend type Foo'), throws);

        expect(
            convertSourceToMap('extend type Foo implements Bar & Baz'),
            convertAstToMap(
                const ast.Document(definitions: [ast.ObjectTypeExtension()])));
      });
    });
  });
}
