part of graphite.language.ast;

class FragmentDefinition extends Definition {
  const FragmentDefinition({
    @required this.name,
    @required this.typeCondition,
    @required this.selectionSet,
    this.directives,
  });

  final String name;
  final TypeCondition typeCondition;
  final Iterable<Directive> directives;
  final SelectionSet selectionSet;

  @override
  NodeKind get kind => NodeKind.fragmentDefinition;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitFragmentDefinition(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'typeCondition': typeCondition,
        'directives': directives,
        'selectionSet': selectionSet,
      };
}
