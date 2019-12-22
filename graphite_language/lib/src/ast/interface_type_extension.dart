part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#InterfaceTypeExtension
class InterfaceTypeExtension extends Extension {
  const InterfaceTypeExtension(
      {@required this.name, this.directives, this.fields});

  final String name;
  final Iterable<Directive> directives;
  final Iterable<FieldDefinition> fields;

  @override
  NodeKind get kind => NodeKind.interfaceTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInterfaceTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
    'kind': kind.toString(),
    'name': name,
    'directives': directives,
    'fields': fields,
  };
}
