part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#Directive
class Directive extends Definition {
  const Directive({@required this.name, this.arguments});

  final String name;
  final Iterable<Argument> arguments;

  @override
  NodeKind get kind => NodeKind.directive;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitDirective(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'arguments': arguments,
      };
}
