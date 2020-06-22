part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#InterfaceTypeDefinition
class InterfaceTypeDefinition extends Definition {
  const InterfaceTypeDefinition(
      {@required this.name, this.description, this.directives, this.fields});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<FieldDefinition> fields;

  @override
  NodeKind get kind => NodeKind.interfaceTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInterfaceTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'description': description,
        'directives': directives,
        'fields': fields,
      };
}
