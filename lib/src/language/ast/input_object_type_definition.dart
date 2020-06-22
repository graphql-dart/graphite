part of graphite.language.ast;

/// A GraphQL Input Object defines a set of input fields; the input fields are
/// either scalars, enums, or other input objects.
///
/// https://graphql.github.io/graphql-spec/draft/#InputObjectTypeDefinition
class InputObjectTypeDefinition extends Definition {
  const InputObjectTypeDefinition({
    @required this.name,
    this.description,
    this.directives,
    this.fields,
  });

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<InputValueDefinition> fields;

  @override
  NodeKind get kind => NodeKind.inputObjectTypeDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInputObjectTypeDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'description': description,
        'name': name,
        'directives': directives,
        'fields': fields,
      };
}
