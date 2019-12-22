part of graphite.language.ast;

class StringValue extends Value<String> {
  const StringValue(String value) : super(value);

  @override
  NodeKind get kind => NodeKind.stringValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitStringValue(this);
}
