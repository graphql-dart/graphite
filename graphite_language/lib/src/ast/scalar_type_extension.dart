part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#ScalarTypeExtension
class ScalarTypeExtension extends Extension {
  const ScalarTypeExtension({@required this.name, @required this.directives});

  final String name;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.scalarTypeExtension;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitScalarTypeExtension(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'directives': directives,
      };
}
