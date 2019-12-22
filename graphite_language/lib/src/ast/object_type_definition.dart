part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ObjectTypeDefinition
class ObjectTypeDefinition extends Definition {
  const ObjectTypeDefinition(
      {@required this.name, this.description, this.directives, this.interfaces, this.fields});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<NamedType> interfaces;
  final Iterable<FieldDefinition> fields;

  @override
  NodeKind get kind => NodeKind.objectTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitObjectTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
    'kind': kind.toString(),
    'name': name,
    'description': description,
    'interfaces': interfaces,
    'directives': directives,
    'fields': fields,
  };
}
