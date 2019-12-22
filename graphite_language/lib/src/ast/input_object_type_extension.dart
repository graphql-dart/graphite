part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#InputObjectTypeExtension
class InputObjectTypeExtension extends Extension {
  const InputObjectTypeExtension({
    @required this.name,
    this.directives,
    this.fields,
  });

  final String name;
  final Iterable<Directive> directives;
  final Iterable<InputValueDefinition> fields;

  @override
  NodeKind get kind => NodeKind.inputObjectTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) =>
      visitor.visitInputObjectTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'directives': directives,
        'fields': fields,
      };
}
