part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumValue
class EnumValue extends Value<String> {
  const EnumValue(String value) : super(value);

  @override
  NodeKind get kind => NodeKind.enumValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitEnumValue(this);
}
