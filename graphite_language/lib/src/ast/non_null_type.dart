part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#NonNullType
class NonNullType extends Node {
  const NonNullType({@required this.type});

  final Node type;

  @override
  NodeKind get kind => NodeKind.nonNullType;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitNonNullType(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'type': type,
      };
}
