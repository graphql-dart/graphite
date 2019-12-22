part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumTypeExtension
class EnumTypeExtension extends Extension {
  const EnumTypeExtension(
      {@required this.name, this.directives, this.values});

  final String name;
  final Iterable<Directive> directives;
  final Iterable<EnumValueDefinition> values;

  @override
  NodeKind get kind => NodeKind.enumTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitEnumTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
    'kind': kind.toString(),
    'name': name,
    'directives': directives,
    'values': values,
  };
}
