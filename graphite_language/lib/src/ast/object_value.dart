part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ObjectField
class ObjectField extends Node {
  const ObjectField({@required this.name, @required this.value});

  final String name;

  final Node value;

  @override
  NodeKind get kind => NodeKind.objectField;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitObjectField(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'value': value,
      };
}

/// https://graphql.github.io/graphql-spec/draft/#ObjectValue
class ObjectValue extends Value<Iterable<ObjectField>> {
  const ObjectValue(Iterable<ObjectField> value) : super(value);

  @override
  NodeKind get kind => NodeKind.objectValue;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitObjectValue(this);
}
