part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#SelectionSet
class SelectionSet extends Definition {
  const SelectionSet({@required this.selections});

  final Iterable<Node /* Field | FragmentSpread | InlineFragment */ >
      selections;

  @override
  NodeKind get kind => NodeKind.selectionSet;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitSelectionSet(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'selections': selections,
      };
}
