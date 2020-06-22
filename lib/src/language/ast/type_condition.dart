part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#TypeCondition
class TypeCondition extends Node {
  const TypeCondition({@required this.name});

  final String name;

  @override
  NodeKind get kind => NodeKind.typeCondition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitTypeCondition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
      };
}
