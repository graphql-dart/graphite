part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#UnionTypeExtension
class UnionTypeExtension extends Extension {
  const UnionTypeExtension(
      {@required this.name, this.directives, this.members});

  final String name;
  final Iterable<Directive> directives;
  final Iterable<NamedType> members;

  @override
  NodeKind get kind => NodeKind.unionTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitUnionTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'directives': directives,
        'members': members,
      };
}
