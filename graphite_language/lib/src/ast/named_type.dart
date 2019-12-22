part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#NamedType
class NamedType extends Node {
  const NamedType({@required this.name});

  final String name;

  @override
  NodeKind get kind => NodeKind.namedType;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitNamedType(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
      };
}
