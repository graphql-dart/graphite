part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#FragmentSpread
class FragmentSpread extends Node {
  const FragmentSpread({@required this.name, this.directives});

  final String name;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.fragmentSpread;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFragmentSpread(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'directives': directives,
      };
}
