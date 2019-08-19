// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

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
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'typeCondition': typeCondition,
        'directives': directives,
        'selectionSet': selectionSet,
      };
}
