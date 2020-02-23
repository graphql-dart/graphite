part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#Alias
class Alias extends Node {
  const Alias({@required this.name});

  final String name;

  @override
  NodeKind get kind => NodeKind.alias;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitAlias(this);
}
