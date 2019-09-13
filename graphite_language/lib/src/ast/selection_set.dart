// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

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