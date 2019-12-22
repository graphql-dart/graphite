part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#EnumTypeDefinition
class EnumTypeDefinition extends Definition {
  const EnumTypeDefinition(
      {@required this.name, this.description, this.directives, this.values});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<EnumValueDefinition> values;

  @override
  NodeKind get kind => NodeKind.enumTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitEnumTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'description': description,
        'name': name,
        'directives': directives,
        'values': values,
      };
}
