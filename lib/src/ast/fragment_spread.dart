// Copyright (c) The Graphite project authors. See AUTHORS file for details.
// All rights reserved.
//
// Use of this source code is governed under the BSD-3-Clause license
// which can be found in the LICENSE file in the root directory of
// this source tree.

part of graphite.language.ast;

/// https://graphql.github.io/graphql-spec/draft/#FragmentSpread
class FragmentSpread extends Node {
  const FragmentSpread({@required this.name, this.directives});

  final String name;
  final Iterable<Directive> directives;

  @override
  NodeKind get kind => NodeKind.fragmentSpread;

  @override
  Map<String, Object> toJson() => {
        'kind': kind.toString(),
        'name': name,
        'directives': directives,
      };
}
