part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ListValue
class ListValue extends Value<List<Node>> {
  const ListValue(List<Node> value) : super(value);

  @override
  NodeKind get kind => NodeKind.listValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitListValue(this);
}
