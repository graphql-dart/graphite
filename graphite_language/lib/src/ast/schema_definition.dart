part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#RootOperationTypeDefinition
class RootOperationTypeDefinition extends Definition {
  const RootOperationTypeDefinition(
      {@required this.operation, @required this.value});

  final OperationType operation;
  final NamedType value;

  @override
  NodeKind get kind => NodeKind.rootOperationTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) =>
      visitor.visitRootOperationTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'operation': operation,
        'value': value,
      };
}

/// https://graphql.github.io/graphql-spec/draft/#SchemaDefinition
class SchemaDefinition extends Definition {
  const SchemaDefinition({
    @required this.definitions,
    this.directives,
  });

  final Iterable<RootOperationTypeDefinition> definitions;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.schemaDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSchemaDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'definitions': definitions,
        'directives': directives,
      };
}
