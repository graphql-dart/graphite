part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#VariableDefinition
class VariableDefinition extends Definition {
  const VariableDefinition({
    @required this.variable,
    this.type,
    this.defaultValue,
    this.directives,
  });

  final Variable variable;
  final Node type;
  final Node defaultValue;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.variableDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitVariableDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'type': type,
        'defaultValue': defaultValue,
        'directives': directives,
      };
}
