part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#IntValue
class IntValue extends Value<int> {
  const IntValue(int value) : super(value);

  @override
  NodeKind get kind => NodeKind.intValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitIntValue(this);
}
