part of graphite.language.ast;

/// Schema extensions are used to represent a schema which has been extended
/// from an original schema. 
///
/// https://graphql.github.io/graphql-spec/draft/#SchemaExtension
class SchemaExtension extends Extension {
  const SchemaExtension({
    this.definitions,
    this.directives,
  });

  final Iterable<RootOperationTypeDefinition> definitions;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.schemaExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSchemaExtension(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'definitions': definitions,
        'directives': directives,
      };
}
