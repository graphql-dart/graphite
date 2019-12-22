part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#UnionTypeDefinition
class UnionTypeDefinition extends Node {
  const UnionTypeDefinition(
      {@required this.name,
      this.description,
      this.directives,
      this.members});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<NamedType> members;

  @override
  NodeKind get kind => NodeKind.unionTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitUnionTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'description': description,
        'directives': directives,
        'members': members,
      };
}
