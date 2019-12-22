part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ScalarTypeDefinition
class ScalarTypeDefinition extends Node {
  const ScalarTypeDefinition(
      {@required this.name, this.description, this.directives});

  final String name;
  final String description;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.scalarTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitScalarTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'description': description,
        'directives': directives,
      };
}
