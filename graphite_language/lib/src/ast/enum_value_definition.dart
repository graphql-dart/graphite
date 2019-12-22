part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumValueDefinition
class EnumValueDefinition extends Definition {
  const EnumValueDefinition(
      {@required this.value, this.description, this.directives});

  final String description;
  final EnumValue value;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.enumValueDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitEnumValueDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'value': value,
        'directives': directives,
      };
}
