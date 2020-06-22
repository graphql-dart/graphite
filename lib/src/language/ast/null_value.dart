part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#sec-Null-Value
class NullValue extends Value<Object> {
  const NullValue(Object value) : super(value);

  @override
  NodeKind get kind => NodeKind.nullValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitNullValue(this);
}
