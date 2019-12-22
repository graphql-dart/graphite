part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#FieldDefinition
class FieldDefinition extends Node {
  const FieldDefinition(
      {@required this.name,
      @required this.type,
      this.description,
      this.directives,
      this.arguments});

  final String name;
  final String description;
  final Iterable<Directive> directives;
  final Iterable<InputValueDefinition> arguments;
  final Node type;

  @override
  NodeKind get kind => NodeKind.fieldDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFieldDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'type': type,
        'description': description,
        'directives': directives,
        'arguments': arguments,
      };
}
