part of graphite.language.ast;

/// https: //graphql.github.io/graphql-spec/draft/#Field
class Field extends Node {
  const Field(
      {@required this.name,
      this.alias,
      this.arguments,
      this.directives,
      this.selectionSet});

  final String name;
  final Alias alias;
  final Iterable<Argument> arguments;
  final Iterable<Directive> directives;
  final SelectionSet selectionSet;

  @override
  NodeKind get kind => NodeKind.field;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitField(this);

  @override
  String toString() => 'Field(kind=$kind, name=$name, alias=$alias)';

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'alias': alias,
        'arguments': arguments,
        'directives': directives,
        'selectionSet': selectionSet,
      };
}
