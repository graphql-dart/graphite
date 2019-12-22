part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#BooleanValue
class BooleanValue extends Value<bool> {
  // ignore:avoid_positional_boolean_parameters
  const BooleanValue(bool value) : super(value);

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitBooleanValue(this);

  @override
  NodeKind get kind => NodeKind.booleanValue;
}
