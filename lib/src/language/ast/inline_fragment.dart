part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#FInlineFragment
class InlineFragment extends Node {
  const InlineFragment(
      {@required this.selectionSet, this.typeCondition, this.directives});

  final TypeCondition typeCondition;
  final Iterable<Directive> directives;
  final SelectionSet selectionSet;

  @override
  NodeKind get kind => NodeKind.inlineFragment;

  @override
  T accept<T>(Visitor<T> visitor) => visitor.visitInlineFragment(this);

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'typeCondition': typeCondition,
        'directives': directives,
        'selectionSet': selectionSet,
      };
}
