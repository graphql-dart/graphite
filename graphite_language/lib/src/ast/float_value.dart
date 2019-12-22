part of graphite.language.ast;

class FloatValue extends Value<double> {
  const FloatValue(double value) : super(value);

  @override
  NodeKind get kind => NodeKind.floatValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFloatValue(this);
}
