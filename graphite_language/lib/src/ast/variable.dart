part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#Variable
class Variable extends Node {
  const Variable({@required this.name});

  final String name;

  @override
  NodeKind get kind => NodeKind.variable;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVariable(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
      };
}
